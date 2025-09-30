---
# allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
argument-hint: session title (optional)
description: Conduct a KPT retrospective and append results to CLAUDE.md upon approval
# model: claude-3-5-haiku-20241022
# disable-model-invocation: true
---

# KPT Retrospective

## Goal

Conduct a Keep-Problem-Try retrospective on the current session and update the repository's CLAUDE.md with actionable insights.

## Keep-Problem-Try Framework

- **Keep**: What worked well and should be continued
- **Problem**: What did not work well or caused issues
- **Try**: How to improve AI agentic work quality in future iterations

## Steps

1. **Keep Analysis**: Review the session to identify what worked well:

   - Effective development approaches that produced good results
   - Helpful codebase patterns or conventions that aided the work
   - Successful tools, commands, or workflows used
   - Architectural decisions that proved beneficial
   - Focus on codebase-wide insights, not one-off implementations

2. **Problem Analysis**: Identify what did not work well and trace to CLAUDE.md content:

   - Review current CLAUDE.md content that may have led to poor decisions or approaches
   - Identify specific lines or sections in CLAUDE.md that caused confusion or bad results
   - Find missing or outdated information in CLAUDE.md that hindered effective work
   - Locate contradictory or unclear instructions that created development friction
   - Note gaps in CLAUDE.md that led to repeated mistakes or inefficiencies

3. **Try Analysis**: Based on identified problems, determine how to improve AI agentic work:

   - Prompt engineering improvements for better task understanding
   - Context or instruction refinements to prevent similar issues
   - Better approaches to tool usage or workflow orchestration
   - Enhanced communication patterns between AI and user
   - Documentation or guidance that would improve future AI sessions

4. **Present KPT Results**: Display retrospective findings to the user in the following format:

   ```
   # Session Retrospective - Keep / Problem / Try

   ## [Keep] (What worked well)

   - [Example]: [Why it worked and how it applies to the codebase]

   ## [Problem] (What did not work well)

   - [Example]: [Which CLAUDE.md entry/section caused or failed to prevent this issue]

   ## [Try] (What to improve next time)

   - [Example]: [How this change will improve AI agentic work quality]

   Do you approve adding these insights to CLAUDE.md?
   ```

   - Provide specific examples and context for each item
   - Explain how each insight applies to the codebase
   - Ask for user approval before updating CLAUDE.md

5. **Locate and Review CLAUDE.md**: Examine the existing CLAUDE.md to understand:

   - Current structure and sections
   - Knowledge already documented
   - Writing style and tone

6. **Update CLAUDE.md**: Apply approved insights to the relevant sections:

   - **Keep items**: Reinforce or expand existing good practices
   - **Problem items**: Document known issues or limitations to avoid repeating mistakes
   - **Try items**: Add improvements to AI agentic work and prompt engineering approaches
   - Match existing writing style and vocabulary
   - Focus on codebase-wide insights that help future Claude sessions

7. **Review and Finalize**: Ensure updates maintain consistency, clarity, and readability

## Important Notes

- Focus on systemic, codebase-wide insights rather than specific implementations
- Problems should capture root causes, not only symptoms
- Try items should be actionable experiments, not vague aspirations
- Verify consistency with existing CLAUDE.md content before updating
- If conflicts arise, request clarification from the user
