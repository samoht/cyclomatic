# TODO

## High Priority

- [x] Implement E350 Boolean Blindness rule
  - Flag functions with 2+ boolean parameters
  - Suggest using variant types instead
  - Example: `create_widget bool -> bool -> t` → use visibility and border types
  - High impact for API clarity

- [x] Implement E351 Mutable State Detection (partial, needs refinement)
  - ✓ Flag use of `ref` and `:=` operator
  - ✓ Updated documentation to clarify only global mutable state is problematic
  - TODO: Distinguish between global and local refs (requires scope analysis)
  - TODO: Detect `mutable` record fields (requires deeper AST analysis)
  - TODO: Detect array creation/mutation at global scope
  - Currently flags all refs, but should only flag module-level refs

- [ ] Fix E105 Catch_all_exception to only detect exception handlers
  - Currently the typedtree patterns don't provide enough context
  - Should only flag patterns like `try ... with _ ->` not all uses of `_`
  - Plan: Use Parsetree traversal with Ast_iterator
    1. Override the expression method to find Pexp_try nodes
    2. Check exception handler cases for Ppat_any patterns
    3. Only flag wildcard patterns within try...with expressions
    4. This avoids false positives for valid underscore uses
  - Implementation would go in lib/style.ml or new lib/ast_checks.ml

- [x] Make E205 Printf_module less strict
  - ✓ Changed title from "Outdated" to "Consider Using Fmt Module"
  - ✓ Description already acknowledges Printf/Format are valid choices
  - ✓ Priority is already medium (3), not highest
  - Rule is now properly framed as a style suggestion

- [x] Enforce 1:1 mapping between test files and library modules
  - ✓ Already implemented as E605 (Missing_test_file) and E610 (Test_without_library)
  - ✓ Checks that each lib/*.ml file has a corresponding test/test_*.ml file
  - ✓ Checks that test files have corresponding library modules
  - ✓ Uses dune describe to find modules accurately
  - Note: May not be showing in output due to dune describe parsing

- [x] Store configuration in .merlintrc or similar config file
  - ✓ Implemented config_file.ml to load .merlintrc files
  - ✓ Searches up directory tree for config file
  - ✓ Supports all existing configuration options
  - ✓ Created .merlintrc.example as documentation
  - ✓ Integrated with main.ml to load config automatically

- [ ] Add code duplication detection
  - Find duplicated code blocks across the codebase
  - Compare AST subtree similarities or use token-based analysis
  - State of the art: structural similarity, clone detection algorithms
  - Could use hash-based detection for exact duplicates
  - Or tree-edit distance for near-duplicates
  - Suggest extracting common code into functions

## Medium Priority

- [ ] Make E415 Missing_standard_function more reasonable
  - Currently requires equal/compare/pp/to_string for ALL types
  - Should only apply to types exposed in .mli files
  - Or make it configurable per project

- [ ] Review E325 Function_naming (get_* vs find_*)
  - Convention is reasonable but not universal in OCaml
  - Standard library doesn't follow this strictly (List.find raises exception)
  - Should be optional/configurable

- [ ] Add missing rules that align with idiomatic OCaml
  - Labeled arguments: Functions with 3+ same-type parameters should use labels
  - Optional argument placement: Optional args should come before mandatory ones
  - No useless open: Avoid `open` when only using 1-2 values from a module

- [ ] Add KISS-derived rules for simplicity
  - E342: Limit function parameters (max 4-5, suggest using records)
  - E343: Flag complex boolean expressions (suggest extracting to named functions)
  - E345: No single-letter variable names (except common idioms like x/xs, i)
  - E348: No magic numbers (require named constants)

- [ ] Implement E352 Generic Label Detection
  - Flag uninformative labels like ~f, ~x, ~k
  - Enforce descriptive API design
  - Good: ~compare, ~initial_value, ~on_error
  - Bad: ~f, ~x, ~k, ~v

- [ ] Implement E353 Modern Concurrency Enforcement
  - Flag direct use of Unix module for concurrent operations
  - Suggest using Eio or Lwt instead
  - Similar to existing Str/Printf rules but for concurrency
  - Allow Unix for non-concurrent operations (file stats, env vars)

- [ ] Add documentation style section for E410
  - E410 exists in error codes but has no reference in style guides
  - Add section to lib/guide.ml explaining expected documentation style
  - Should explicitly reference [E410] for documentation style issues

- [ ] Implement E411: Docstring Format Convention
  - Enforce `[function_name arg1 arg2] is ...` pattern for function docs
  - Use regex to check docstrings in .mli files start with `[<name> ...] is`
  - Ensures consistent documentation style across codebase

- [x] Add rule E340 to catch Error patterns and suggest using err_* helper functions (partial)
  - ✓ Added issue types and documentation  
  - ✓ Created infrastructure for detecting `Error (Fmt.str ...)` patterns
  - TODO: Current implementation needs deeper AST analysis to properly detect the pattern
  - Would need to analyze constructor applications with function calls as arguments
  - Typedtree doesn't provide enough context for this pattern

- [ ] Implement E510: Missing Log Source
  - Each module should define its own log source
  - Check that every .ml file contains at least one `Logs.Src.create` call
  - Ensures proper logging configuration per module

- [ ] Implement E620: Test Name Convention
  - Test suite names should be lowercase, single words
  - Test case names should be lowercase with underscores
  - Inspect string literals passed to `Alcotest.test_case` and suite names

- [ ] Implement E326: Redundant 'get_' Prefix
  - Simple accessors shouldn't have `get_` prefix (use `User.name` not `User.get_name`)
  - Reserve `get_` for functions with non-trivial computation that succeed
  - Flag `get_*` functions that are just simple record field access
  - Requires semantic analysis of function body

- [ ] Implement E331: Missing Labels for Same-Type Parameters
  - When a function has 2+ parameters of the same type, labels should be used
  - Prevents confusion and argument order mistakes (e.g., `copy ~from ~to`)
  - Check function signatures for multiple parameters with identical types
  - Suggest adding labels when this pattern is detected

## Low Priority

- [ ] Merge redundant testing guides
  - prompts/test.md and prompts/tests.md have overlapping content
  - Creates confusion about which is authoritative
  - Use prompts/tests.md as base (more detailed)

- [ ] Investigate why we have test_style_rules and test_rules_integration that don't correspond to any lib/*.ml files
  - These test files exist but don't follow the 1:1 correspondence rule
  - Decide if they should be renamed or excluded from the check


## Function Naming Convention Rule

Implement a rule to enforce function naming conventions:

- **`get_*`** - for functions that extract/retrieve something from an existing structure
  - Should return the value directly (not wrapped in option)
  - Example: `get_field record` returns `string`

- **`find_*`** - for functions that search for something that might not exist  
  - Should return an option type
  - Example: `find_user_by_id id` returns `user option`

### Implementation Notes

This requires Merlin integration for accurate type analysis:

1. **Use `ocamlmerlin single outline`** to get function signatures:
   ```bash
   echo "let get_user_by_id id = Some user" | ocamlmerlin single outline file.ml
   ```
   This gives us structured information about all functions, their names, and types.

2. **Use `ocamlmerlin single type-enclosing`** for precise type information:
   ```bash
   echo "let find_user id = None" | ocamlmerlin single type-enclosing -position 1:15 file.ml
   ```
   This can give us the exact return type of functions.

3. **Parse function signatures** to detect option return types:
   - Look for functions ending with `option` in their return type
   - Check if function names match the semantic convention

4. **Flag violations**:
   - `extract_*`, `locate_*`, `search_*` should be renamed to `get_*` or `find_*`
   - `get_*` functions returning option should be `find_*`
   - `find_*` functions not returning option should be `get_*`

### Current Status
- Issue type `Bad_function_naming` is defined and partially implemented
- Currently checks get_/find_ naming based on return types from outline
- Could be enhanced with more semantic analysis

### Integration with Existing Code
This would fit well with the existing `merlin_interface.ml` module:
- Add `get_outline` function similar to existing `analyze_file`
- Add `get_type_at_position` function for type queries
- Create new `naming_analysis.ml` module for function naming checks
- Call from `naming_rules.ml` alongside other naming checks

## Other Improvements

- Enhance catch-all exception detection with better AST parsing
- Add more comprehensive documentation rules
- Improve complexity analysis for more OCaml constructs
- Add configuration file support for customizing thresholds

