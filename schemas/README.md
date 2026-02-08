# Waldiez Schemas

## Current Status (v0.1-alpha)

MANIFEST and .wid files reference:

```yaml
$schema: "https://xperiens.waldiez.io/schema/v1/manifest"
```

**This URL is reserved but not yet published.**

## What This Means

- The `$schema` field documents the **intended** schema version
- Formal JSON Schema validation is **planned** but not yet implemented
- Current validation uses structural checks in CI/scripts

## Current Validation

**MANIFEST validation:**

- `scripts/validation/check_manifest_sections.sh` - Section integrity
- Pre-commit hooks - Structure validation
- CI workflows - Automated checks

**See:** `docs/SPECIFICATION.md` Section 3.3 for MANIFEST structure

## Roadmap

| Version | Deliverable |
| ------- | ----------- |
| v0.2 | JSON Schema file (`manifest-v1.schema.json`) |
| v0.3 | YAML validation tooling integration |
| v0.4 | .wid schema file |
| v1.0 | Schema publication at waldiez.io domain |

## Why Not Now?

**v0.1-alpha focuses on:**

- Proving the waldiez concept
- Establishing file contracts
- Demonstrating automation patterns

**Formal schemas add:**

- Complexity in maintenance
- Rigidity during exploration phase
- Tooling dependencies

**Strategy:** Let the specification stabilize through real-world use before formalizing schemas.

## Contributing

If you'd like to contribute schema definitions, please:

1. Review `docs/SPECIFICATION.md` thoroughly
2. Create draft in `schemas/drafts/`
3. Test against existing MANIFESTs
4. Submit PR with test coverage

---

**Last updated:** 2026-02-08  
**Specification version:** 0.1-alpha
