Test bad example - should find missing standard functions:
  $ merlint -r E415 bad.mli
  Running merlint analysis...
  
  Analyzing 1 files
  
  ✓ Code Quality (0 total issues)
  ✓ Code Style (0 total issues)
  ✓ Naming Conventions (0 total issues)
  ✗ Documentation (1 total issues)
    [E415] Missing Standard Functions (1 issue)
    The main type 't' should implement standard functions: equal, compare, and pp
    (pretty-printer) for better usability and consistency across the codebase. For
    simple types, polymorphic equal (=) and compare functions are sufficient. For
    more complex types with invariants or custom representations, implement
    specialized versions.
    - bad.mli:1:0: Type 't' is missing standard functions: equal, compare, pp
  ✓ Project Structure (0 total issues)
  ✓ Test Quality (0 total issues)
  
  Summary: ✗ 1 total issue (applied 1 rule)
  ✗ Some checks failed. See details above.
  [1]

Test good example - should find no issues:
  $ merlint -r E415 good.mli
  Running merlint analysis...
  
  Analyzing 1 files
  
  ✓ Code Quality (0 total issues)
  ✓ Code Style (0 total issues)
  ✓ Naming Conventions (0 total issues)
  ✓ Documentation (0 total issues)
  ✓ Project Structure (0 total issues)
  ✓ Test Quality (0 total issues)
  
  Summary: ✓ 0 total issues (applied 1 rule)
  ✓ All checks passed!
