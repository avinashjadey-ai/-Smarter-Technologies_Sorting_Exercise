# Package Sorter — Snowflake SQL UDF

A Snowflake SQL UDF that dispatches packages to the correct stack based on their volume, dimensions, and mass.

## Function Signature

sql
SORT(WIDTH FLOAT, HEIGHT FLOAT, LENGTH FLOAT, MASS FLOAT) RETURNS VARCHAR


## Stack Definitions

| Stack | Condition |

| `STANDARD` | Not bulky and not heavy |
| `SPECIAL` | Bulky or heavy (but not both) |
| `REJECTED` | Bulky and heavy |

## Classification Rules

**Bulky** — either condition qualifies:
- Volume (Width × Height × Length) ≥ 1,000,000 cm³
- Any single dimension ≥ 150 cm

**Heavy:**
- Mass ≥ 20 kg

## Logic Flow

The UDF uses a 'CASE' statement that evaluates conditions in order of most to least restrictive:

1. **REJECTED** — checked first. If the package is both bulky AND heavy, it is rejected immediately.
2. **SPECIAL** — if the package is bulky OR heavy (but not both), it requires special handling.
3. **STANDARD** — default fallback for packages that meet neither condition.

This ordering ensures no package is misclassified at the boundaries.

## Setup & Usage

1. Run 'sort_packages.sql' in a Snowflake worksheet to create the UDF and execute test cases.
2. The test suite covers individual cases and a batch validation using `VALUES`.

sql
SELECT SORT(100, 100, 100, 20);  -- Returns: REJECTED
SELECT SORT(10, 10, 10, 5);      -- Returns: STANDARD


## Edge Cases Covered

- Dimensions and volume at exact boundary values (150 cm, 1,000,000 cm³, 20 kg)
- Package just under bulky volume threshold but heavy
- Package bulky by dimension but not by volume
