## AI Prompt Optimization Implementation Guide

Version: 0.1.0

### Objective
Implement a repeatable process to audit, standardize, evaluate, and continuously improve AI agent prompts across the repository.

### Prerequisites
- Read `docs/development/AI_PROMPT_STRATEGY_PLAN.md`
- Ensure CI and documentation rules are followed

### Step 1: Inventory and Categorize
1. Discover prompt docs in root and `docs/development/`
2. Categorize by purpose: generation, review, planning, process
3. Record location, version, last updated, owner

### Step 2: Standardize Templates
1. Apply the standard sections:
   - Mission
   - Context files to link
   - Your task
   - Focus
   - Key requirements
   - Success criteria
   - Start here
2. Add branch/PR rules when implementation is required

### Step 3: Integrate with Workflow
1. Cross-link prompts with `PROJECT.md`, CRAN and pre-PR validation docs
2. Ensure privacy-first, CRAN readiness requirements appear where relevant

### Step 4: Evaluation Framework
1. Add a mini rubric per prompt: clarity, completeness, correctness
2. Collect usage feedback and outcome notes in a changelog

### Step 5: A/B Testing and Feedback
1. For high-usage prompts, maintain two variants
2. Compare outcomes and converge on best version

### Step 6: Automation Opportunities
1. Script inventory and validation checks (naming, sections present)
2. Consider generating copyable agent messages from a template file

### Step 7: Maintenance Cadence
1. Quarterly review cycle: open issues for needed updates
2. Version bumps with concise changelog entries

### Success Criteria
- All prompts conform to template
- Documented evaluation and feedback loop exists
- Clear ownership and update cadence

### Deliverables
- Updated prompt files with headings and version tags
- Inventory record (in docs or issue tracker)
- A/B test notes for key prompts

### Reference
- `docs/development/AI_PROMPT_STRATEGY_PLAN.md`

