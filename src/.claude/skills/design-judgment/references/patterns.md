# Design Judgment — Anti-Pattern Reference

16 patterns of design judgment failure, each with axis bias, typical examples, and the criteria under which the pattern is a deliberate choice rather than a failure. Notation defined in the parent `SKILL.md`.

The dominant failure mode is **support axis mismatch**: the axis the decider treats as dominant differs from the one the situation actually demands. Read each pattern as "what does the decider's axis profile look like when they fall into this trap."

---

## 1. Reinventing the Wheel

A standard solution exists, but the decider builds a custom one.

**Axis bias**

- Purpose fit ↑
- Coherence ↓
- Feasibility (technical) ↓
- Quality impact (maintainability) ↓

**Typical**

- Building custom token auth instead of using a standard library
- Hand-rolling authorization with `Filter` + `ThreadLocal` when the framework's security module would suffice
- Pushing constraints into application `if` blocks that the database could express
- Returning HTTP 200 with a custom error code instead of using HTTP status codes
- Writing a `Thread` + `while(true) + sleep` scheduler when `@Scheduled` or Quartz is available

**When deliberate**

- The standard solution measurably fails a primary constraint (performance, security, contractual)
- The differentiation gained from custom implementation clearly outweighs the cost of leaving the standard path

**Agent note.** AI-generated code "works" but often departs from the framework's idiomatic path. The judgment "you don't normally hand-roll this" doesn't surface from the model — it has to come from the human or from an explicit instruction to prefer in-framework solutions.

---

## 2. Sledgehammer for a Nut

Industrial-scale solution applied to small-scale problem.

**Axis bias**

- Purpose fit ↑
- Feasibility (technical) ↓
- Time effect (short) ↓
- Quality impact (operability) ↓
- Agreement ↓

**Typical**

- 30-user internal admin tool designed as 4 microservices from day one
- Event sourcing for a 4-state workflow (draft → submitted → approved → final)
- Kafka + consumer groups for a 500-record daily CSV ingest
- Camunda for a one-step "request → manager approval" flow
- Spark cluster on Kubernetes CronJob for a monthly report
- Drools for input validation of "required / length / regex"

**When deliberate**

- A learning/PoC where exercising the heavy stack is itself the goal
- Roadmap commits to reaching the scale within 1–2 years
- The org already operates the heavy stack and incremental operational cost is small

**Agent note.** Models pull in "well-known best practices" without weighing whether the context is sufficient. Expect drift toward whatever looks impressive in general write-ups.

---

## 3. Design Beyond Org Capability

Technically sound design that the operating team cannot run. Technical feasibility is satisfied; organizational feasibility is not.

**Axis bias**

- Feasibility (technical) ↑
- Feasibility (organizational) ↓
- Quality impact (operability) ↓
- Risk / uncertainty ↓

**Typical**

- Multi-region active-active for a team without 24/7 on-call
- Production Kubernetes/Kafka without an operator on staff — vendor-dependent operations
- Trunk-based with daily releases imposed on a weekly-release team
- Multi-master DB or sharding without a DBA
- SLO/error-budget rhetoric without an SRE who can measure them
- CD pipeline into an org whose release approval is still manual

**When deliberate**

- A skill-acquisition plan and migration schedule are agreed, with explicit education window and external support timeline
- External SRE/vendor will operate it for a defined period, with internalization milestones

**Agent note.** Models do not know the org's skill profile. Pasting "the recommended architecture" without organizational context guarantees a mismatch. Encode operating-team assumptions in the agent instructions; otherwise the answer drifts toward best-practice defaults.

---

## 4. Skill-Fear Downgrade

Underestimating team skill, the decider downgrades to a technically inferior choice. Phrases like "the team can't handle this" or "we won't be able to maintain it" are used to reject standard solutions or appropriate abstractions. Common in SIer contexts where "maintainability" is invoked to justify the lowest-common-denominator choice.

**Axis bias**

- Feasibility (organizational) ↓
- Risk / uncertainty ↑
- Quality impact (maintainability) ↑
- Quality impact (evolvability) ↓
- Time effect (long) ↓
- Coherence ↓

**Typical**

- Banning Java Lambda / Stream API as "people won't read it"; mandating extended `for` loops
- Banning `Optional` as "the meaning won't carry"; pushing `null` checks back to callers indefinitely
- Staying on JavaScript when TypeScript would fit, on the grounds that "no one can maintain type definitions"
- Banning `git rebase` / `squash` as "history rewrite is dangerous"; merge-commits-only
- Rejecting CI/build automation as "no one can maintain it"; preserving manual releases

**When deliberate**

- A time-boxed holding pattern while the skill plan and migration schedule are being assembled — record the deadline and the conditions for moving on
- The system is short-lived and the education ROI does not balance

**Agent note.** This is **deliberately accepted** technical debt that reads as "realistic judgment" to both decider and reviewer, which is exactly why it's hard to challenge. The pattern silently consumes the team's opportunity to build the skill.

---

## 5. Stopgap Fix

Short-term path makes the code compile or pass, so the decider stops thinking before the design question is reached.

**Axis bias**

- Time effect (short) ↑
- Coherence ↓
- Quality impact ↓
- Time effect (long) ↓

**Typical**

- Swallowing an exception so the screen advances
- Adding logic to a Controller because that's where the bug surfaced, ignoring the existing layering
- Putting a domain rule in screen-side validation only
- Adding `if (x != null)` to dodge a single NullPointerException, ignoring why `x` was null
- Editing the test's expected value because the implementation changed

**When deliberate**

- Initial incident response where stopping the bleeding outweighs everything else — **always** leave the timestamp, the rollback condition, and a permanent-fix ticket
- No other deliberate use. Pausing while the system is in an inconsistent state means the permanent fix never lands

**Agent note.** Time(short) as the dominant axis is the most common path to this trap. AI emits locally-passing code fast; only the human can apply the brake.

---

## 6. Premature Success ("Execution Hallucination")

Confusing "the command returned" / "the test went green" / "got a 200" with "the goal was met."

**Axis bias**

- Purpose fit unobservable
- Coherence ↓
- Risk / uncertainty ↓

**Typical**

- HTTP 200 treated as success when the side effect didn't happen
- INSERT silently rejected, but "save succeeded" recorded
- External API send "succeeded" but the receiver did not accept the payload
- Batch job ran to completion against zero rows
- A `console.log` left in place is logged as "logging done"
- Migration completed without error against a non-existent table

**When deliberate**

- None. Replace exit-code/return-value checks with **business-level acceptance** verification
- For temporary smoke tests, mark "not yet verified" explicitly and ticket the real verification

**Agent note.** Agents treat exit codes and return values as success conditions. A "succeeded" report from an agent means "the command finished" — nothing more.

---

## 7. Premature Implementation Start

Either requirements are not defined, or the implementation strategy is not defined, but coding starts. Both forms hide the decision behind "wait until something runs." Pre-AI as well, but Vibe Coding accelerates the trap.

**Axis bias**

- Purpose fit unobservable
- Constraint fit unobservable
- Quality impact unobservable
- Time effect (short) ↑
- Agreement ↓

**Typical**

- Generating screens / API / DB while requirements are still vague
- Building "something that runs" with no acceptance criteria
- Implementing validation before business rules are defined
- Writing exception handling before the business meaning of errors is decided
- Hiding UI for permissions before the permission model exists
- Writing migration scripts before the reconciliation policy is decided
- Adding a Redis cache layer before knowing the target throughput

**When deliberate**

- A spike intended as throwaway exploration — record the deletion date and the deletion owner alongside the code
- Pre-agreed that the spec is exploratory; the real implementation will start on a different branch

**Agent note.** "Working code" obscures the gap. Vibe Coding produces something that runs, so requirement gaps and strategy gaps look filled-in by the implementation.

---

## 8. Premature Abstraction

**Axis bias**

- Quality impact (changeability) ↑
- Purpose fit ↓
- Feasibility (technical) ↓
- Time effect (short) ↓

**Typical**

- Strategy pattern introduced when there is one implementation
- Generic form renderer built when there is one form
- Settings stored in DB with an admin screen, when no new settings are planned
- Custom DSL designed when the search has two filters (`name`, `status`)
- Generic CSV import framework for one screen and one fixed format

**When deliberate**

- None as a default. Abstract once the variation point has been observed at least twice (Rule of Three)
- Exception: the abstraction itself is the learning goal — build it as a spike, not in production code

**Agent note.** The words *flexibility* and *extensibility* in a justification are the strongest tell. This is changeability overweighted relative to current Purpose fit.

---

## 9. Constraints Bolted On

In business systems the constraints **are** the body. Permissions, history, audit, idempotency, and state transitions belong in the data model and use cases from the start, not as later additions.

**Axis bias**

- Constraint fit ↓
- Risk / uncertainty ↓
- Quality impact ↓

**Typical**

- Build CRUD, then bolt on permissions
- Build the update path, then bolt on the audit log
- Build delete, then notice the retention requirement
- Build the synchronous integration, then bolt on retry and idempotency
- Build address update, then notice past invoices need to re-render

**When deliberate**

- None for new design. Embed the constraints in the data model and use cases up front
- For changes to live code, this is a separate problem: add a constraint-respecting path, deprecate the old path, and treat it as a phased migration with explicit termination conditions

**Agent note.** Vibe Coding makes the visible feature appear fast, so constraints are perceived as "additional implementation" rather than load-bearing structure. The faster generation gets, the more visible this anti-pattern becomes.

---

## 10. Over-Deference to Legacy

Without checking who actually uses the legacy interface and what compatibility is really required, the decider assumes maximum conservatism and chooses a complex path. Sibling pattern of *Speculative extension point* (`#16`) but pointed backwards in time.

**Axis bias**

- Constraint fit ↑
- Purpose fit ↓
- Feasibility (technical) ↓
- Quality impact (maintainability) ↓
- Time effect (short) ↓

**Typical**

- Running old and new endpoints in parallel forever to avoid breaking an existing API
- Never dropping DB columns; `is_deleted`, `is_archived`, `is_suspended` accumulate
- Never modifying enums; every new value goes in a separate field
- A `version` field branching parsing logic, fattening with each release
- Deprecated config keys preserved with a startup-time bridge from old to new
- Staying on Spring Boot 2 so 3-only features are filled in by hand
- Not migrating existing data; new and old formats supported simultaneously in code

**When deliberate**

- Public / contractual APIs whose users live outside the org and cannot absorb migration cost
- Compliance or audit obligations require preserving old data formats / interfaces
- In all cases, write down the **scope preserved**, the **end date**, and the **deprecation plan**. Open-ended compatibility guarantees are not allowed

**Agent note.** Agents take "do not break existing code" as a hard constraint. Telling them "keep existing tests passing" pushes them toward the most complex solution that satisfies the literal constraint without questioning whether it should hold. A human asks "is this compatibility actually required?" first; the agent does not.

---

## 11. Acceptance Criteria in Name Only

Acceptance criteria exist as text but are not decomposed into something verifiable. "Displays correctly," "logs appropriately," "behaves under normal load." Distinct from *Premature implementation start* (`#7`): there, the criteria are absent; here, they exist but cannot be checked.

**Axis bias**

- Agreement ↓
- Purpose fit unobservable
- Quality impact unobservable

**Typical**

- "Displays correctly"
- "Errors as appropriate"
- "Performs at normal speed"
- "Same as the current system"
- "Logs appropriately"
- "User-friendly"

**When deliberate**

- None. Decompose into specific input / state / expected result / exception conditions before starting

**Agent note.** Pre-AI problem amplified by Vibe Coding: AI produces plausible-looking acceptance criteria at scale, making the gap harder to spot.

---

## 12. Cross-Boundary Implementation

**Axis bias**

- Coherence ↓
- Quality impact (maintainability) ↓
- Risk / uncertainty ↓

**Typical**

- Order-amount limit checking written in the Controller instead of the domain
- "Show the delete button to admins" decided directly inside the Blade / JSX template
- `ORDER BY CASE WHEN status = 'urgent' THEN 0 ELSE 1 END` — view-layer concern embedded in SQL
- A nightly batch baked with "if X happens, notify Slack and stop, expecting an operator to resume"
- One `OrderDto` carrying both JPA `@Column` and presentation `@JsonFormat`

**When deliberate**

- A bug in the canonical structure makes fixing the responsibility-owner's location too expensive right now — accept the boundary violation with an explicit rollback condition and a permanent-fix ticket
- A framework or library constraint forbids placing the logic at the responsibility-owner's location — leave a comment recording the constraint

**Agent note.** AI tends to optimize for "where does this make it work right now" rather than "where does this belong."

---

## 13. Best-Practice Imposition over Local Convention

**Axis bias**

- Coherence ↓
- Purpose fit ↓
- Feasibility (technical) ↓

**Typical**

- Existing code uses checked exceptions for business errors; new AI-written code unifies on `RuntimeException`
- Log-level policy is defined; AI-written code uses `info` for everything
- Convention is to open transactions in the service layer; new code adds `@Transactional` to the Controller
- Convention requires the in-house date utility; new code calls `java.time` directly
- Tests are JUnit 4 `@Rule`; new tests are JUnit 5 `@ExtendWith` only because that's the modern default
- Spring Boot defaults applied where the company's EAP / Jakarta EE constraints forbid them

**When deliberate**

- The existing convention is genuinely outdated and a convention update can pass review — propose the convention change **and** the new code together
- The existing convention has safety / security problems and aligning the new code is the correct direction — write the migration plan and the disposition for legacy code

**Agent note.** This is born from AI filling gaps with "general web-development" knowledge. Without an explicit instruction to read the project's existing code first, the rate of this pattern does not drop.

---

## 14. Reimplementation Without Lookup

Existing function / class / utility is not read; a parallel one with the same role is created. Direct path to *Comprehension Debt* in Addy Osmani's sense.

**Axis bias**

- Coherence ↓
- Quality impact (maintainability) ↓
- Agreement ↓

**Typical**

- Common date utility exists; `formatDate`, `dateToString`, `toIsoDate` accumulate side by side
- Convention requires a Repository layer; a new Service writes raw SQL anyway
- Validation rules are shared; a new screen writes them locally as a one-off
- Authorization is in a Decorator / Interceptor; a new endpoint puts the check at the top of the Controller
- A `Money` class exists; new calculation logic uses `BigDecimal` directly
- Domain constants are in `Constants.java`; another file redefines them

**When deliberate**

- The existing implementation has hard constraints (performance, compatibility, frozen call sites) that make a new path cheaper for this case — write down the deprecation plan for the existing implementation
- The existing implementation has grown over-broad; the new piece is intentionally split out — annotate that this is a *separation*, not a duplication

**Agent note.** Agents tend to read only the area surrounding the instruction location. Without an explicit "search for an existing implementation of the same role before writing a new one" instruction, near-duplicate functions multiply. CLAUDE.md or its equivalent should make this lookup mandatory before file creation.

---

## 15. Hallucinated Dependency

Code calls a library / function / argument signature / method that does not exist. Causes are stale training data and confusion across similar libraries. Researched as *package hallucination*.

**Axis bias**

- Feasibility (technical) ↓
- Risk / uncertainty ↓
- Constraint fit ↓

**Typical**

- Importing a non-existent package that `pip install` happens to accept (slopsquatting risk: an attacker can pre-register the same name)
- Calling pandas `df.append(other)` — existed in old versions, removed now
- Passing plausible-but-nonexistent argument names: `requests.get(url, timeout=5, retry=3)`
- Mixing similar libraries' APIs (lodash vs underscore, moment vs dayjs)
- Calling an in-house utility name extrapolated from naming conventions, that does not exist
- Accessing a property absent from a TypeScript type definition and pushing through with `@ts-ignore`

**When deliberate**

- None. Verify against primary sources (official docs, source) and confirm by execution before introducing a new library or API

**Agent note.** Outsourcing feasibility checks to the agent produces "looks-like-it-runs but doesn't" code at volume. Documentation lookup tooling and execution confirmation are prerequisites for trusting the output.

---

## 16. Speculative Extension Point

Adjacent to *Premature abstraction* (`#8`); distinguish them as follows:

- *Premature abstraction*: variation point has not yet been observed even once when the abstraction is introduced
- *Speculative extension point*: variation is mentioned verbally but no time, owner, or benefit is bound to it

The bias mix differs too: *Premature abstraction* is changeability overweighted; this one is **time(long) overweighted**. Different cures, so kept separate.

**Axis bias**

- Time effect (long) ↑
- Time effect (short) ↓
- Feasibility (technical) ↓
- Risk / uncertainty ↓

**Typical**

- "Maybe we'll support multiple databases" → abstract DAOs added
- "Maybe we'll add SMS / LINE alongside email" → general-purpose notification platform
- "Maybe rules will multiply" → Drools introduced
- "Maybe we'll go multi-language" → all labels routed through message resources
- "Maybe we'll switch payment providers" → a payment-provider abstraction layer up front

In every case, no one and no date is bound to the future variation.

**When deliberate**

- The roadmap binds a time and an owner to the variation — extension points only for **committed** future change
- A structural location (public API, persistent schema) where retrofitting a variation point is extremely expensive
- Otherwise: abstract once the variation has actually been observed

---

## Cross-References

- The *agent note* on most patterns identifies the AI-specific failure mode. When generating non-trivial structure, scan #6, #10, #13, #14, #15 in particular — these are the patterns where the agent is the most likely first-order cause
- For decision-quality framing across multiple competing proposals, pair this reference with explicit advocate/critic analysis on the dominant axis
