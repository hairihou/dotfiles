---
# allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
# argument-hint: [message]
description: Extract key project insights and update CLAUDE.md with actionable improvements
# model: claude-3-5-haiku-20241022
# disable-model-invocation: true
---

# Session Insight

Extract project-specific insights from the session to update CLAUDE.md with _ULTRATHINK_.

## 3-Axis Analysis

- **Goal Achievement**: Objective completion effectiveness
- **Efficiency**: Process and resource optimization
- **User Satisfaction**: Emotional experience and frustration analysis

## Output Requirements

**ALWAYS** use user language for output.

## Analysis Ratings

Rating guide: ★☆☆☆☆ Failed/Very poor | ★★☆☆☆ Poor | ★★★☆☆ Adequate | ★★★★☆ Good | ★★★★★ Excellent

## Steps

0.  **Preparation**: Review session context and notes

    - Understand project goals and user expectations
    - Identify key events and actions taken during the session

    **Output Template:**

    ```
    Starting session analysis...
    ```

1.  **Analysis: Goal Achievement**: Evaluate objective completion

    - Task completion status and quality
    - Project outcomes delivered
    - Goals missed and blockers

    **Output Template:**

    ```
    ## Goal Achievement: ★★★☆☆ (3/5)

    - [Reason 1]
    - [Reason 2]
    - [Reason 3]
    ```

2.  **Analysis: Efficiency**: Assess process optimization

    - Effective vs ineffective approaches
    - Resource waste patterns
    - Future optimization opportunities

    **Output Template:**

    ```
    ## Efficiency: ★★★☆☆ (3/5)

    - [Reason 1]
    - [Reason 2]
    - [Reason 3]
    ```

3.  **Analysis: User Satisfaction**: Analyze emotional experience

    - AI actions triggering negative reactions
    - Frustration patterns and root causes
    - Expectation violations and communication issues

    **Output Template:**

    ```
    ## User Satisfaction: ★★★☆☆ (3/5)

    - [Reason 1]
    - [Reason 2]
    - [Reason 3]
    ```

4.  **Thinking: Synthesize Insights**: Two improvement types:

    **Codebase**: Lint/test/refactor changes enhancing AI coding
    **LLM Context**: CLAUDE.md updates improving AI understanding

5.  **Report: Present Insights for LLM Context Improvements**: Display only the most critical improvements for user approval:

    **Output Template:**

    ```
    ## LLM Context Improvements

    - ADD: [New context to add]: [How it improves AI understanding]
    - DELETE: [Context to remove]: [Why it causes problems]
    - MODIFY: [Context to modify]: [Current issue] → [Improved version]

    Do you approve these LLM context improvements for CLAUDE.md updates?
    ```

    Principles: Extracted insights only, project-relevant, actionable, organized by type

6.  **Action: Review CLAUDE.md**: Check structure and style
7.  **Action: Apply LLM Improvements**: Update CLAUDE.md with approved insights
8.  **Report: Present Codebase Improvements**:

    ```
    ## Codebase Improvements Suggestions

    - [Specific codebase change]: [How it enhances AI coding quality]
    - Example: Add ESLint rules for consistent imports - Reduces AI confusion about module resolution

    Would you like me to create GitHub issues for these codebase improvements?
    ```

9.  **Action: Create Issues (If Approved)**: Make GitHub issues with detailed descriptions:

    ```
    Title: [Improvement Type]: [Brief description]
    Example: "Code Quality: Add ESLint rules for consistent imports"

    Body:
    ## Context

    Identified during AI coding session retrospective

    ## Problem

    [Root cause that led to AI coding issues]

    ## Proposed Solution

    [Specific change and implementation approach]

    ## Expected Benefit

    [How this enhances future AI coding quality]

    ## Priority

    [Low/Medium/High based on impact]
    ```

10. **Finalize**: Ensure consistency

## Guidelines

- Project-specific insights only
- Root causes, not symptoms
- Concrete improvements, not vague aspirations
- Prevent frustration patterns
- Verify CLAUDE.md consistency
