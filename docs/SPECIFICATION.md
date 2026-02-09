# The Waldiez Experience - Technical Specification

**Version:** 0.1-alpha  
**Status:** Living specification  
**Last updated:** 2026-02-08

---

## 1. Purpose & Vision

The **Waldiez Experience** defines an ecosystem where entities and capabilities—from IoT devices to AI workflows to individual functions—are represented as **waldiez** (singular: waldiez, plural: waldiez).

Each waldiez is paired with a formal, machine-readable specification called an **agent** that:

- Describes what the waldiez is (identity, purpose, capabilities)
- Exposes how to interact with it (operations, state schema)
- Tracks its evolution over time (history, versioning)
- References its execution, discovery, and lifecycle dependencies

**The agent is not the thing itself**—it's the **formal representation** that makes the waldiez discoverable, inspectable, and composable within the ecosystem.

### Examples

| Waldiez | Agent Contains |
| ------- | ------------- |
| Smart water heater | Control API, current temperature, heating schedule, MQTT endpoint |
| LLM processing pipeline | Execution graph, runtime requirements, state checkpoints |
| Home climate system | Member references, orchestration rules, aggregate state |
| Method: `celsius_to_fahrenheit()` | Parameters, return type, implementation reference, version |
| Time passage tracker | Tick log, temporal rules, existence proof |

The long-term goal is an ecosystem where agents enable waldiez to be:

- **Read** (understood and rendered by tools)
- **Renderer** (played/executed or simulated)
- **Edited** (authored and evolved)
- **Observed** (audited across time and versions)

---

## 2. Core Concepts

### 2.1 Waldiez and Agents

A **waldiez** is any entity in the ecosystem that has identity and behavior.

Waldiez exist at multiple scales:

- **Atomic**: Individual methods, functions, data transformations
- **Component**: Devices, services, workflows, processes
- **Composite**: Systems, orchestrations, groups of waldiez
- **Semantic**: Ontologies, vocabularies, formal models

An **agent** is the formal specification of a waldiez, expressed as:

- **`.waldiez`** format (zip-based micro-repository for complex entities)
- **`.wid`** format (lightweight descriptor file for atomic waldiez)

Every waldiez has a unique **Waldiez ID (WID)** in URI form:

```text
wdz://authority/path/version
```

Examples:

- `wdz://waldiez.local/time/clock/v1`
- `wdz://stdlib/math/celsius-to-fahrenheit/v1`
- `wdz://myorg/workflows/data-pipeline/v3.1`

---

### 2.2 The `.waldiez` Format (Heavyweight Agents)

A **`.waldiez`** artifact is a **zip-based micro-repository** encapsulating a complete agent specification for complex waldiez.

#### Mandatory Contents

Any `.waldiez` zip archive **MUST** contain:

- **`.tic`** — Creation timestamp (immutable birth certificate)
- **`MANIFEST`** — Agent specification (identity, interface, state, references)

#### Common Optional Contents

- **`.toc`** — Timeline / heartbeat log (for time-aware waldiez)
- **`README.md`** — Human-readable overview
- **`PLAN.md`** — Lifecycle and evolution plan
- **`/methods/`** — Directory of `.wid` files for sub-operations
- **`/data/`** — State snapshots, datasets, or artifacts
- **Custom files** — As defined by the MANIFEST

---

### 2.3 The `.wid` Format (Lightweight Agents)

A **`.wid`** file is a **single-file agent descriptor** for atomic waldiez (typically methods, functions, or simple transformations).

Structure:

```yaml
$schema: "https://xperiens.waldiez.io/schema/v1/manifest"
wid: "wdz://authority/path/version"
name: "celsius_to_fahrenheit"
type: "method"
created: "2026-02-07T11:45:00Z"

interface:
  params:
    celsius: {type: float, unit: celsius}
  returns: {type: float, unit: fahrenheit}
  
implementation:
  ref: "./celsius_to_fahrenheit.py"
  runtime: "wdz://runtimes/python3.11"
```

**When to use `.wid` vs `.waldiez`:**

- Use `.wid` for atomic, stateless operations (methods, pure functions)
- Use `.waldiez` for complex entities with state, history, or dependencies

---

### 2.4 Canonical Working Tree vs Packaged Artifacts

The **canonical form** of a waldiez agent in this repository is an **unpacked working tree** (a directory under the repository root).

A `.waldiez` zip file is a **packaged artifact**, used for distribution, transport, and consumption by external tools.

**Rules:**

- Automation and CI agents **operate on directories**, not on zip files
- `.waldiez` zip files **MAY be produced** by tooling or CI, but **ARE NOT required** to be committed to `main`
- Tooling **MAY accept** either a directory or a `.waldiez` zip as input, but **MUST** normalize to a working directory before applying mutations

This distinction enables:

- Human-readable diffs and reviews
- Deterministic automation
- Clean separation between source-of-truth and distributable artifacts

---

## 3. File Contracts (Normative)

### 3.1 `.tic` — Birth Certificate (Immutable)

- Exactly **one line**
- UTC timestamp in ISO-8601 format:

```text
2026-02-07T11:45:00Z
```

- **MUST NOT** change after creation
- Defines the agent's temporal origin
- Establishes the waldiez's identity in time

---

### 3.2 `.toc` — Timeline / Heartbeat (Append-Only)

**Purpose:** Record observable existence through time for time-aware waldiez.

- One line per UTC day:

```text
2026-02-07
2026-02-08
2026-02-09
```

- Sorted in ascending order
- No duplicates
- Append-only under normal operation

**Not all waldiez require `.toc`** — only those representing time-based processes or requiring existence proof over time.

#### 3.2.1 Heartbeat vs Tick

**Heartbeat:** Proof of operational existence at a specific timestamp.

- Recorded in `MANIFEST.state.last_heartbeat`
- Updated whenever health check runs
- May occur multiple times per day

**Tick:** Proof of existence on a specific UTC day.

- Recorded in `.toc` as one line per day
- Updated only when a new UTC day is encountered
- Represents conceptual timeline

A waldiez may receive many heartbeats but only one tick per day.

---

### 3.3 `MANIFEST` — Agent Specification

The **MANIFEST** is the core specification file that defines the waldiez agent.

Format: **YAML** (recommended) or **TOML**

### 3.3.1 Required Structure

```yaml
# ===== SCHEMA & IDENTITY (Immutable) =====
$schema: "https://xperiens.waldiez.io/schema/v1/manifest"

identity:
  wid: "wdz://authority/path/version"    # Globally unique Waldiez ID
  type: "device|workflow|group|method|process|..."
  created: "2026-02-07T11:45:00Z"        # From .tic, immutable
  
description:
  name: "Human-readable name"
  purpose: "Brief statement of what this waldiez does"
  tags: ["tag1", "tag2"]

# ===== INTERFACE (Stable, rarely changes) =====
interface:
  operations:
    - wid: "wdz://..."                   # Reference to operation (may be .wid file)
      name: "operation_name"
      params: {param1: type1, ...}
      returns: type
      
  state_schema:                          # Defines shape of mutable state
    field1: {type: type1, unit: unit1, mutable: true}
    field2: {type: type2, mutable: bool}

# ===== STATE (Mutable, automation may modify) =====
state:
  field1: value1
  field2: value2
  last_updated: "2026-02-07T14:30:22Z"

# ===== EXECUTION & LIFECYCLE (References) =====
execution:
  runtime: "wdz://..."                   # Reference to execution environment
  protocol: "wdz://..."                  # Communication protocol
  
discovery:
  advertise: "wdz://..."                 # How this waldiez is discovered
  
lifecycle:
  health_check: "wdz://..."              # Health monitoring mechanism
  depends_on: ["wdz://...", ...]         # Required dependencies
  part_of: ["wdz://...", ...]            # Parent/container waldiez
```

### 3.3.2 Section Ownership

| Section | Mutability | Who Can Modify |
| ------- | ---------- | -------------- |
| `identity` | Immutable | Never (except WID version bump via new agent) |
| `description` | Rare changes | Humans only |
| `interface` | Rare changes | Humans only |
| `state` | Frequent changes | Automation allowed (within schema) |
| `execution` | Occasional changes | Humans only |
| `discovery` | Occasional changes | Humans only |
| `lifecycle` | Occasional changes | Humans only |

**Critical Rule:** Automation (CI, scripts, bots) **MUST ONLY** modify the `state` section and **MUST** respect the `state_schema` constraints.

---

### 3.3.3 Semantic Layer (Optional)

Waldiez MAY include semantic annotations to link with formal ontologies and enable richer discovery, composition, and reasoning.

**Design principle:** Semantic annotations are **completely optional**. Waldiez work perfectly without ontologies. Add semantic enrichment only when it provides value.

#### Ontology Reference

Link to external ontology:

```yaml
ontology:
  ref: "https://w3id.org/saref/core"
  concepts:
    - "saref:HVAC"
    - "saref:TemperatureSensor"
  properties:
    - "saref:hasTemperature"
    - "saref:hasSetPoint"
```

#### Ontology Embedding

Include ontology directly:

```yaml
ontology:
  format: "turtle"  # or "rdf-xml", "json-ld"
  content: |
    @prefix sh: <https://example.org/smart-home#> .
    @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    
    sh:SmartThermostat rdf:type rdfs:Class ;
        rdfs:label "Smart Thermostat" .
  
  # Or reference file in .waldiez archive
  file: "./smart-home.ttl"
```

#### Semantic Annotations

Annotate waldiez properties with semantic meaning:

```yaml
semantics:
  # Link to standard vocabulary
  vocabulary: "http://schema.org/"
  
  # Unit ontology links (e.g., QUDT)
  units:
    temperature: "http://qudt.org/vocab/unit/DEG_C"
    setpoint: "http://qudt.org/vocab/unit/DEG_C"
  
  # RDF triples about this waldiez
  rdf: |
    @prefix : <#> .
    @prefix qudt: <http://qudt.org/schema/qudt/> .
    
    : a :SmartDevice ;
        qudt:hasUnit qudt:DEG_C .
```

#### Complete Example

```yaml
$schema: "https://xperiens.waldiez.io/schema/v1/manifest"

identity:
  wid: "wdz://devices/thermostat-01"
  type: "device"
  created: "2026-02-08T10:00:00Z"

description:
  name: "Living Room Thermostat"
  purpose: "Control temperature in living room"

# Standard waldiez interface
interface:
  operations:
    - name: "getTemperature"
      returns: {type: float, unit: celsius}
    - name: "setTemperature"
      params:
        target: {type: float, unit: celsius}

# OPTIONAL: Semantic enrichment
ontology:
  ref: "https://w3id.org/saref/core"
  concepts: ["saref:HVAC", "saref:TemperatureSensor"]

semantics:
  units:
    temperature: "http://qudt.org/vocab/unit/DEG_C"
  vocabulary: "https://w3id.org/saref/"
```

#### Ontology as Waldiez Type

Ontologies themselves can be waldiez:

```yaml
$schema: "https://xperiens.waldiez.io/schema/v1/manifest"

identity:
  wid: "wdz://ontologies/smart-home/v1"
  type: "ontology"
  created: "2026-02-08T10:00:00Z"

description:
  name: "Smart Home Ontology"
  purpose: "Formal description of smart home devices and concepts"
  tags: ["ontology", "smart-home", "iot"]

ontology:
  format: "turtle"
  file: "./smart-home.ttl"
  base_uri: "https://example.org/smart-home#"

lifecycle:
  depends_on:
    - "wdz://ontologies/saref/v1"  # Built on SAREF
```

#### Rules and Conventions

**Optional Nature:**

- Semantic annotations are OPTIONAL
- Waldiez work without ontologies
- Add semantics only when valuable
- Not all waldiez need semantic enrichment

**Ontology Formats:**

- Supported: Turtle (.ttl), RDF/XML (.rdf), JSON-LD (.jsonld)
- Turtle is RECOMMENDED for human readability

**References:**

- Ontology URIs SHOULD be dereferenceable
- Use standard ontologies when possible:
  - SAREF: Smart home/IoT (<https://w3id.org/saref/>)
  - QUDT: Units and quantities (<http://qudt.org/>)
  - Schema.org: General vocabulary
  - FOAF: People and organizations
  - PROV-O: Provenance

**Tooling:**

- Tools MAY use ontologies for reasoning
- Tools MAY validate semantic consistency
- Tools MUST work with waldiez that lack ontologies

#### Use Cases

**IoT Devices:**
Link devices to standard ontologies like SAREF for interoperability.

**Scientific Methods:**
Annotate with QUDT units for automatic unit validation and conversion.

**Domain Models:**
Distribute ontologies as waldiez for versioning and composition.

**Discovery:**
Find waldiez by semantic concepts rather than just names.

**Reasoning:**
Infer relationships between waldiez based on ontological reasoning.

#### Future Work

- SPARQL query interface for semantic discovery
- Ontology reasoning integration
- Standard vocabulary library
- Semantic composition patterns

---

### 3.4 Waldiez ID (WID) Format

**Syntax:**

```text
wdz://authority/path/version
```

**Components:**

- **Scheme:** Always `wdz://`
- **Authority:** DNS-like authority (domain, org identifier)
- **Path:** Hierarchical path to the waldiez
- **Version:** Semantic version (major.minor.patch) or date-based

**Examples:**

```text
wdz://waldiez.local/time/clock/v1
wdz://stdlib/math/conversions/celsius-to-fahrenheit/v1
wdz://myorg.internal/workflows/etl/customer-data/v2024.02.07
```

**Rules:**

- WIDs **MUST** be globally unique
- Changing the version creates a **new waldiez** (new identity)
- WIDs **SHOULD** be dereferenceable (resolve to agent artifact or registry entry)

---

## 4. Reference Resolution

When a MANIFEST contains references like:

```yaml
runtime: "wdz://runtimes/python3.11"
depends_on: ["wdz://acme.com/thermostat-01"]
```

**Resolution mechanism** (in order of precedence):

1. **Local registry:** Check `./waldiez.registry.yaml` for local mappings
2. **Embedded references:** Check `/references/` directory in the `.waldiez` archive
3. **Network resolution:** HTTP(S) GET to `https://waldiez.org/resolve?wid=...`
4. **Well-known locations:** Check standard paths (e.g., `~/.waldiez/registry/`)

**Tooling requirements:**

- Tools **MUST** support local registry resolution
- Tools **MAY** support network resolution
- Tools **MUST** gracefully handle unresolvable references (warn, don't fail)

---

## 5. Design Principles

### 5.1 Core Tenets

1. **Self-description over convention**  
   Agents explicitly declare their behavior, not rely on implicit patterns.

2. **Explicit state over implicit behavior**  
   State changes are tracked and auditable.

3. **Portable logic, thin platform wrappers**  
   Core logic in scripts, CI just orchestrates.

4. **Auditability through time**  
   Git provides immutable history of all changes.

5. **Minimalism and atomic commits**  
   Each commit represents one logical state transition.

6. **Scales from atomic to composite**  
   Same model applies to methods, devices, and systems.

7. **References enable composition**  
   Waldiez compose via WID references, not tight coupling.

---

### 5.2 Non-Negotiable Constraints (v1)

These constraints apply to **version 1** of the specification. Future versions may relax or modify them.

- `.tic` immutability
- `MANIFEST` section ownership rules
- WID uniqueness
- Automation limited to `state` section modifications

---

## 6. Repository Structure

This repository (`waldiez/xperiens`) follows this structure:

```text
waldiez/xperiens/
├── README.md                      # Dynamic status (updated by CI)
├── START_HERE.md                  # Static guide
│
├── time/                          # Time-based waldiez
│   └── clock/                    # First reference implementation
│
├── devices/                       # Future: IoT device waldiez
├── methods/                       # Future: .wid files
├── workflows/                     # Future: workflow waldiez
├── systems/                       # Future: composite waldiez
│
├── tools/                         # Future: player, editor, studio
│   ├── player/
│   ├── editor/
│   └── studio/
│
├── scripts/
│   ├── agents/                   # Waldiez-specific updaters
│   └── validation/               # Integrity checks
│
├── .github/workflows/            # CI orchestration
└── docs/                         # Documentation
```

---

## 7. Open Questions & Future Work

### 7.1 Schema Versioning

- How do waldiez migrate between schema versions?
- Backward/forward compatibility strategies?

### 7.2 Network Resolution

- Standard protocol for WID resolution over HTTP(S)?
- Decentralized vs. centralized registry model?

### 7.3 Security & Trust

- WID signature verification?
- Permission model for state modifications?
- Sandboxing for execution?

### 7.4 Composition Semantics

- When a composite waldiez references members, what are the lifecycle contracts?
- Cascade deletion? Independent lifecycle?

### 7.5 Validation

- How to verify an agent accurately represents its waldiez?
- Runtime contracts and monitors?

### 7.6 Semantic Integration

- How to discover waldiez by semantic concepts?
- Should there be a standard semantic registry?
- Ontology versioning and migration strategies?
- Integration with existing ontology tools (Protégé, reasoners)?
- Performance implications of semantic reasoning?

---

## 8. Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 0.1-alpha | 2026-02-07 | Initial specification: core concepts, MANIFEST structure, time/clock example |
| 0.1-alpha-ontology | 2026-02-08 | Add optional semantic layer with ontology support (Section 3.3.3) |

---

## Appendices

### Appendix A: MANIFEST JSON Schema

**Status:** Planned for v0.2

MANIFEST and .wid files reference:

```yaml
$schema: "https://xperiens.waldiez.io/schema/v1/manifest"
```

**Current state (v0.1-alpha):**

- MANIFEST structure is defined in Section 3.3
- Validation via `scripts/validation/check_manifest_sections.sh`
- See `schemas/README.md` for detailed roadmap

**Planned for v0.2:**

- JSON Schema file at `schemas/manifest-v1.schema.json`
- YAML validation tooling integration
- Schema hosting at waldiez.io domain

### Appendix B: Complete time/clock Example

*(See: `/time/clock/` in repository)*

### Appendix C: Glossary

**Agent:** Formal specification of a waldiez  
**Waldiez:** Any entity with identity and behavior in the ecosystem  
**WID:** Waldiez ID, globally unique identifier in URI form  
**MANIFEST:** Core specification file in an agent  
**.waldiez:** Heavyweight agent format (zip archive)  
**.wid:** Lightweight agent format (single YAML file)  
**.tic:** Immutable creation timestamp  
**.toc:** Timeline/heartbeat log  
**Ontology:** Formal description of concepts and relationships in a domain  
**Semantic Layer:** Optional ontology annotations that enrich waldiez with formal semantics  
**RDF:** Resource Description Framework, W3C standard for semantic data  
**Turtle:** Text-based RDF serialization format (.ttl files)  
**SAREF:** Smart Appliances REFerence ontology (<https://w3id.org/saref/>)  
**QUDT:** Quantities, Units, Dimensions, and Types ontology (<http://qudt.org/>)  
**OWL:** Web Ontology Language for formal ontologies  
**SPARQL:** Query language for RDF data

---
That's it
**End of specification**
