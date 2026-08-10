# Frontend design lock

Use this gate after the user selects a Product Design visual and before `image-to-code`, scaffolding, or production frontend edits.

## 1. Freeze the visual source

Record the supplied attachment, URL capture, screenshot, Figma frame, mockup, or existing screen as grounding context. Always generate one batch of exactly three independent visual options, record the three unique displayed result IDs in displayed order, and record the selected result and selection source. A number is valid only when it resolves unambiguously to that displayed order. If the user requests a visual refinement or combines options, generate and show a new three-option batch before continuing.

## 2. Decompose the page structure

Create a compact structure map:

- surfaces, pages, routes, tabs, and overlays;
- viewport sections in reading and focus order;
- primary outcome, CTA, supporting actions, and content priority;
- component boundaries and real asset sources;
- mobile/tablet/desktop changes;
- loading, empty, error, permission, disabled, submitting, success, and destructive states.

Give each page or surface a `PAGE-NNN` record with route/surface, ordered viewport sections, content priority, component/asset boundaries, responsive structure, visible states, and an `Affordances` field listing every visible or user-triggered `AFF-NNN` on that surface.

Present the structure before interaction questions. Give material alternatives when hierarchy, navigation ownership, or responsive composition could change the result. Record `Structure status: APPROVED` and its user approval source before opening interaction decisions.

## 3. Build the interaction inventory

Account for every user-triggered behavior. Use these categories:

| Category | Cover |
|---|---|
| Navigation | Route/page/tab switching, back behavior, deep links, state and scroll restoration |
| Scroll | Native flow, sticky regions, anchors, section reveal, pagination/infinite loading, snap behavior, back-to-top |
| Controls | Buttons, CTAs, links, toggles, filters, hover/focus/pressed/disabled/loading/success/destructive behavior |
| Forms | Validation timing, submit behavior, errors, retries, unsaved changes, keyboard/focus order |
| Overlays | Menus, drawers, modals, popovers, dismissal, focus trap, background interaction |
| State | Loading, optimistic/pessimistic updates, empty/error/success feedback, recovery and idempotent repeats |
| Responsive input | Mouse, keyboard, touch, swipe, device rotation, breakpoint behavior |
| Motion | Page/control transition, duration/easing intent, interruption, and reduced-motion alternative |

Map every declared `AFF-NNN` exactly once in the coverage matrix. A `COMPLETE` row maps to one real `INT-NNN`; an `INHERITED` row maps to an `INT-NNN` whose decision record is explicitly accepted as inherited; a `NON_INTERACTIVE` row contains a concrete `REASON:`. The locked set of declared affordance IDs and coverage-row IDs must match exactly. Do not leave decorative controls that appear actionable. Set `Coverage status: COMPLETE` only when every affordance is accounted for.

## 4. Ask interaction decisions

For each material interaction:

1. State the surface, trigger, and user outcome.
2. Offer exactly three materially distinct valid options.
3. Put the recommendation first and give one trade-off per option.
4. Ask one dependent decision at a time. Independent decisions may be shown as a small group only when each can be answered separately without hidden coupling.
5. Leave `Status: OPEN` until the user chooses; never treat the recommendation as consent.
6. Record outcome, materiality, `Selected option`, `Status: SELECTED`, decision source, dependencies, relevant states, and `INT-ACC-NNN` IDs inside that same decision record.

Do not offer unsafe, inaccessible, or contract-invalid choices merely to reach three. When the governing design system or safety contract permits only one behavior, explain the constraint and ask the user to accept it as `INHERITED`; otherwise keep the design `DRAFT`.

## 5. Lock package

The package must contain:

- exact selected visual source;
- approved page/route/section structure;
- component and asset map;
- interaction register with no open material decisions and a complete affordance coverage matrix;
- state and transition flow;
- responsive, keyboard, touch, focus, and reduced-motion behavior;
- visual and `INT-ACC-NNN` acceptance traceability;
- remaining non-material polish explicitly deferred;
- approval source, revision, and contract fingerprint.

Show the package to the user and request the final lock. Set `Design status: LOCKED` only after explicit approval. Record approval source, revision, and a fingerprint of the selected source, structure, interactions, and acceptance contract.

## 6. Build boundary

Before lock, allow only Product Design context gathering, reference inspection, ideation, structure/interaction specification, and non-production throwaway flow diagrams when the user asks for them. Do not scaffold, start a server, call `image-to-code`, or edit production frontend files.

After lock, pass both the exact visual target and the lock package to `image-to-code`. The selected image governs visual fidelity; the interaction register governs behavior. If implementation exposes a missing decision or any material locked field changes, return the design to `DRAFT`, invalidate the fingerprint, ask the user, update acceptance, and re-lock before continuing.
