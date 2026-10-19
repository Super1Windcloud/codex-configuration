---
name: figma-to-compose
description: Implement Figma frames and component sets as production-ready Android Jetpack Compose UI, including project-aware Material 3 styling, design-token mapping, previews, and automatic conversion of eligible Figma vector icons to Android VectorDrawable XML through Figma Desktop MCP and Android MCP Toolkit. Use when the user provides a Figma URL or node ID and asks to build, recreate, translate, or update an Android screen or component in Compose, especially when icons should be extracted from Figma. Do not use for XML Views, non-Android UI, or code-to-Figma work.
---

# Figma to Compose

Implement the selected Figma node in the user's Android project. Treat Figma MCP output as design evidence, not as production code to copy verbatim.

## Required inputs

Require an exact Figma URL or node ID. Ask one concise question only when the target cannot be resolved, multiple plausible frames remain, or the requested destination cannot be inferred from the repository.

Default to:

- Jetpack Compose with the project's existing Material version; use Material 3 for a new project.
- A screen, reusable components, theme-token additions, drawable resources, and at least one meaningful preview.
- Existing project architecture, package names, components, tokens, navigation, and state patterns.

## Tool handling

Use the currently available tools matching these capabilities; MCP server prefixes and argument names can vary by environment:

- Figma: `get_metadata`, `get_variable_defs`, `create_design_system_rules`, `get_design_context`, and `get_screenshot`.
- Android conversion: `convert-svg-to-android-drawable`.
- Android diagnostics, only when the user asks to debug an integrated build: `read-adb-logcat`, `get-pid-by-package`, `get-current-activity`, `fetch-crash-stacktrace`, `check-anr-state`, and `clear-logcat-buffer`.

Discover available MCP tools before relying on them. Never invent a tool result. If a capability is unavailable, continue with repository and available Figma evidence, state the limitation, and use the fallback defined below.

If another applicable Figma skill is installed, follow its required Figma read workflow as well. This skill owns the Android Compose translation and drawable-output rules.

## Workflow

### 1. Inspect the Android project

Before generating code:

1. Locate the target module, source set, package, Gradle Compose configuration, min SDK, and Material dependency.
2. Find nearby screens and shared UI primitives. Reuse the project's theme, typography, spacing, image loader, icon wrapper, navigation, state model, and preview conventions.
3. Check the worktree and preserve unrelated changes.
4. Decide whether the request is a new screen, a component replacement, or a narrow update. Keep edits within that boundary.

Do not create parallel `Color.kt`, `Type.kt`, or `Dimens.kt` files when equivalent project-owned token files already exist.

### 2. Resolve and capture the Figma target

1. Call `get_metadata` for the supplied URL or node ID.
2. Confirm the exact frame or component and record its name, dimensions, children, variants, and component-instance relationships.
3. Call `get_screenshot` for the resolved root before implementation. Use it as the visual reference.
4. For large screens, identify logical sections and retrieve focused context for each section rather than requesting an excessively broad tree.

### 3. Read tokens and design context

1. Call `get_variable_defs` and preserve variable names, modes, aliases, alpha values, typography, spacing, and radii when available.
2. Call `create_design_system_rules` when the tool exists and the file contains a design system. Treat its output as guidance, then reconcile it with repository tokens.
3. Call `get_design_context` for the root and any section whose layout or assets remain ambiguous.
4. Prefer repository tokens when they intentionally correspond to Figma semantics. Add the smallest missing token surface needed by the target.
5. Preserve exact Figma values for one-off measurements unless Android constraints or existing design tokens justify an adaptation. Document material adaptations.

Do not assume Figma pixels always equal Android `dp`. Use frame density context, existing mobile design conventions, screenshots, and repository baselines. Preserve proportions when the density is unknown.

### 4. Translate to idiomatic Compose

Map design intent rather than generated web structure:

- Vertical auto layout -> `Column` or `LazyColumn` when content scrolls or repeats.
- Horizontal auto layout -> `Row` or lazy horizontal containers for repeated content.
- Layering -> `Box`; avoid offsets and absolute placement unless the design genuinely overlaps.
- Gap -> `Arrangement.spacedBy`; padding -> `Modifier.padding`.
- Fill or hug sizing -> Compose constraints such as `fillMaxWidth`, `weight`, `wrapContentSize`, and `requiredSize` only when required.
- Radius, stroke, clipping, and shadow -> Compose shapes, `border`, `clip`, and `shadow` in an order that preserves rendering.
- Text -> project typography or a named `TextStyle`; preserve size, weight, line height, alignment, overflow, and max lines.
- Repeated patterns and Figma variants -> reusable composables with typed parameters or enums.
- Interactive controls -> real Compose controls with enabled, pressed, selected, loading, empty, and error states evidenced by the design or existing product behavior.

Keep state hoisted. Provide a stateless content composable for previews and a route or stateful wrapper only when the project architecture calls for one. Do not invent networking, navigation destinations, analytics, or business behavior absent from the request or repository.

Use stable responsive constraints. Avoid hardcoded full-screen coordinates, magic spacer stacks, nested cards, and decorative abstractions that exist only to mimic a screenshot.

### 5. Run the icon pipeline automatically

Perform this pass without waiting for a separate icon request.

#### Detect candidates

Traverse metadata under the selected target and collect nodes that satisfy at least one condition:

- Type is `VECTOR` or `BOOLEAN_OPERATION`.
- Name resembles `icon`, `ic_`, `glyph`, or a semantic icon component.
- It is a small, approximately square node, usually 12-48 design units, whose fills or strokes resemble an icon.
- It is an icon component instance or property exposed by metadata.

Exclude logos, photographs, complex illustrations, masks, and vectors whose gradients or effects cannot be represented faithfully by VectorDrawable. Treat those as image assets.

#### Obtain source data

For each unique icon source:

1. Call `get_design_context` on the icon node.
2. Use SVG markup, path data, or an MCP-provided asset reference only when it is actually present and complete.
3. Optionally call `get_screenshot` to disambiguate or verify the visual.
4. Deduplicate repeated instances by semantic icon and variant.

Never reconstruct an SVG path from a screenshot.

#### Convert and verify

When complete SVG is available:

1. Normalize the semantic name to lowercase snake case.
2. Strip one leading `icon_` or `ic_`, then write `ic_<semantic_name>.xml`.
3. Call `convert-svg-to-android-drawable`; do not hand-convert complex SVG paths when the converter is available.
4. Save the result under the target module's appropriate `src/<sourceSet>/res/drawable` directory.
5. Check XML validity, viewport and intrinsic dimensions, fill/stroke colors, alpha, fill type, and clipping. Prefer tintable theme colors when the same asset is recolored by UI state.

Do not overwrite an existing drawable with different semantics. Reuse a visually equivalent existing project drawable when appropriate.

#### Batch fallback

If MCP does not expose complete SVG data, finish all other safe work and ask once for a batch SVG export. Report an `Assets Needed (SVG export)` table containing semantic name, Figma node ID, intended drawable filename, and reason conversion is blocked. Include or reference a screenshot preview when the tool supplies one.

For raster images, report the node ID, intended filename, recommended format, and density or sizing assumptions. Do not substitute a placeholder unless the user explicitly accepts one.

### 6. Validate

1. Compare the implementation with the root Figma screenshot for hierarchy, spacing, typography, color, clipping, and major alignment.
2. Run focused formatting, resource/XML validation, compilation, lint, or tests supported by the project and task scope.
3. Render Compose previews or capture the integrated screen when the environment supports it. Compare at the same viewport when possible.
4. Verify light/dark behavior and dynamic text only when the project or design supports them.
5. Clearly separate verified results from unverified approximations such as unavailable fonts, blur, complex shadows, or missing assets.

Do not use Android runtime diagnostic tools during normal design translation. Use them only for a user-reported crash or ANR after integration, and return the root cause plus the smallest actionable patch.

## Deliverables

Adapt paths and filenames to the repository. For a new conventional screen, prefer:

```text
ui/screen/<feature>/<ScreenName>Screen.kt
ui/screen/<feature>/<ScreenName>Components.kt   # only when extraction is useful
ui/theme/Color.kt                               # update existing file when present
ui/theme/Type.kt                                # update existing file when present
ui/theme/Dimens.kt                              # only for genuinely reused dimensions
src/main/res/drawable/ic_<name>.xml
```

Include in the final response:

- Implemented screen/components and their paths.
- `Generated VectorDrawables`: each created or reused drawable.
- `Mapping Notes`: token mapping, responsive behavior, and intentional deviations.
- `Assets Needed`: only unresolved SVG, raster, or font assets.
- Validation performed and any remaining mismatch risk.

Do not claim pixel-perfect parity unless both the rendered Compose result and Figma reference were compared at equivalent dimensions.

## Naming

Normalize icon names to lowercase snake case, replace spaces, slashes, and dashes with underscores, collapse duplicate underscores, and retain meaningful variant suffixes.

Examples:

- `Icon/Search` -> `ic_search.xml`
- `ic_home_filled` -> `ic_home_filled.xml`
- `home-24` -> `ic_home_24.xml`
