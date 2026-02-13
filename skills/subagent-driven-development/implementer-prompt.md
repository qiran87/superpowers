# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent.

```
Task tool (general-purpose):
  description: "Implement Task N: [task name]"
  prompt: |
    You are implementing Task N: [task name]

    ## Task Description

    [FULL TEXT of task from plan - paste it here, don't make subagent read file]

    ## Context

    [Scene-setting: where this fits, dependencies, architectural context]

    ## Before You Begin

    If you have questions about:
    - The requirements or acceptance criteria
    - The approach or implementation strategy
    - Dependencies or assumptions
    - Anything unclear in the task description

    **Ask them now.** Raise any concerns before starting work.

    ## Your Job

    Once you're clear on requirements:
    1. Implement exactly what the task specifies
    2. Write tests (following TDD if task says to)
    3. Verify implementation works
    4. Commit your work
    5. Self-review (see below)
    6. Report back

    Work from: [directory]

    **While you work:** If you encounter something unexpected or unclear, **ask questions**.
    It's always OK to pause and clarify. Don't guess or make assumptions.

    ## Before Reporting Back: Self-Review

    Review your work with fresh eyes. Ask yourself:

    **Completeness:**
    - Did I fully implement everything in the spec?
    - Did I miss any requirements?
    - Are there edge cases I didn't handle?

    **Quality:**
    - Is this my best work?
    - Are names clear and accurate (match what things do, not how they work)?
    - Is the code clean and maintainable?

    **Discipline:**
    - Did I avoid overbuilding (YAGNI)?
    - Did I only build what was requested?
    - Did I follow existing patterns in the codebase?

    **Testing:**
    - Do tests actually verify behavior (not just mock behavior)?
    - Did I follow TDD if required?
    - Are tests comprehensive?
    - **Are tests organized by requirement?** (See Test Organization below)
    - **For web UI testing:** Use chrome-devtools-mcp MCP tools for browser automation, testing, and debugging

    If you find issues during self-review, fix them now before reporting.

    ## Test Organization (Requirement-Based)

    **If this task is part of a requirement:**

    Tests must be organized in the requirement-based structure:
    ```
    tests/requirements/YYYY-MM-DD-requirement-name/
    ├── README.md
    ├── tasks.md
    ├── test.sh
    ├── unit/
    │   └── feature.test.ts
    └── integration/
        └── flow.test.ts
    ```

    **Required Test File Metadata:**

    Every test file MUST include this header:
    ```typescript
    /**
     * [Test Suite Name]
     *
     * @requirement YYYY-MM-DD-requirement-name
     * @task task-id-task-name
     * @created YYYY-MM-DD
     * @author AI Agent (subagent-driven-development)
     */
    ```

    **Steps:**
    1. Create/update test file in appropriate directory (unit/ or integration/)
    2. Add required metadata header
    3. Follow TDD: Write test → Run RED → Implement → Run GREEN
    4. Update `tasks.md` with test case list and status
    5. Run `./test.sh` to verify all tests pass

    **Test File Creation:**
    - Unit tests go in `unit/` directory
    - Integration tests go in `integration/` directory
    - Test file name should reflect the feature being tested
    - One task can have multiple test files if logical grouping exists

    **After Implementation:**
    - Update `tasks.md`: Mark task as ✅ Completed, add test case list
    - Update `README.md`: Update progress statistics
    - Commit with message: `feat(scope): description (Task #N of Req #YYYY-MM-DD-name)`

    **Verification:**
    ```bash
    cd tests/requirements/YYYY-MM-DD-requirement-name
    ./test.sh
    ```

    See: `docs/test-organization-guide.md` for complete details.

    ## Web UI Testing with chrome-devtools-mcp

    **When to use:** For testing web applications, browser automation, UI interactions, and debugging frontend issues.

    **Available MCP Tools:**
    - **Navigation:** `navigate_page`, `new_page`, `list_pages`, `select_page`
    - **Interaction:** `click`, `fill`, `fill_form`, `hover`, `press_key`, `drag`
    - **Analysis:** `take_snapshot`, `take_screenshot`, `evaluate_script`
    - **Debugging:** `list_console_messages`, `list_network_requests`, `get_console_message`, `get_network_request`
    - **Performance:** `performance_start_trace`, `performance_stop_trace`, `performance_analyze_insight`
    - **Emulation:** `emulate` (viewport, network, geolocation, CPU throttling, user agent)
    - **Dialog/Upload:** `handle_dialog`, `upload_file`

    **Testing Workflow:**
    1. **Setup:** Start browser and navigate to test URL
    2. **Snapshot:** Take initial snapshot for element reference
    3. **Interact:** Perform user actions (click, fill forms, navigate)
    4. **Verify:** Check console messages, network requests, DOM state
    5. **Debug:** Analyze failures with console logs, network traces
    6. **Performance:** Run performance traces for critical user flows

    **Example Test Case:**
    ```bash
    # Navigate to page
    mcp__chrome-devtools__navigate_page url="http://localhost:3000/login"

    # Take snapshot to get element UIDs
    mcp__chrome-devtools__take_snapshot

    # Fill login form
    mcp__chrome-devtools__fill_form elements='[{"uid": "email-input", "value": "test@example.com"}, {"uid": "password-input", "value": "password123"}]'

    # Click submit button
    mcp__chrome-devtools__click uid="submit-button"

    # Wait for navigation
    mcp__chrome-devtools__wait_for text="Dashboard"

    # Verify console has no errors
    mcp__chrome-devtools__list_console_messages types='["error", "warning"]'

    # Verify API requests
    mcp__chrome-devtools__list_network_requests resourceTypes='["xhr", "fetch"]'
    ```

    **Integration with Test Files:**
    - Create test files in `tests/requirements/YYYY-MM-DD-name/integration/` for end-to-end UI tests
    - Use MCP tools within test execution flow
    - Capture screenshots and console logs for debugging
    - Store test artifacts (screenshots, traces) in `tests/requirements/YYYY-MM-DD-name/artifacts/`

    **Report Format

    When done, report:
    - What you implemented
    - What you tested and test results
    - Files changed
    - Self-review findings (if any)
    - Any issues or concerns
```
