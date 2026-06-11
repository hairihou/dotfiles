---
name: system-layering
description: Localize a failure in a multi-stage chain (pipeline stages, client → server → datastore) by collecting evidence at every hand-off before reasoning about fixes. Use when the failing stage is unknown or a previous fix attempt did not hold. Not for single-component bugs where a stack trace already names the cause.
---

# System Layering

Where an error becomes visible and where it is introduced are usually different stages of the chain. Identify the stage before reasoning about the fix; patching at the visible end hides the cause.

## Procedure

1. Sketch the chain the request, artifact, or signal travels through, end to end
2. Add temporary instrumentation at every hand-off — record what each stage receives and what it emits, and confirm settings and environment variables survive each hop — so a single run yields evidence for the whole chain
3. Walk the evidence from the start and find the earliest hand-off where reality stops matching expectation; only that stage is under investigation now
4. Follow the corrupt value backward to where it was first produced and correct it there, never at the stage where the symptom appeared
5. Vary one thing at a time: state the suspected cause, change the least amount of code that would confirm or deny it, and never pile a second change onto an unconfirmed first

## When Fixes Keep Failing

A run of unsuccessful corrections — three is a sensible line — is evidence about the design, not bad luck. So is a fix that resolves one symptom only to surface a new one elsewhere. Stop producing patches at that point and bring the collected evidence and the design question to the user.
