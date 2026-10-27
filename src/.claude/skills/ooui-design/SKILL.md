---
name: ooui-design
description: Structure an application's screens around the objects users work with (nouns) instead of the tasks they perform (verbs), with a list and a detail view per object, navigation between related objects, and actions offered after an object is selected. Use when designing or building the screens, navigation, or routing of a web app or business system, and when reviewing one. Not for a surface whose whole job is one task, such as a login page, a checkout, or a one-shot converter, nor for how a single screen is laid out visually.
---

# OOUI Design

Users think in the things they handle, such as an order, a customer, or a document, and decide what to do after they see it. A menu of tasks makes them pick the action before the object, then holds them inside that task's flow. Derive screens from objects first, and turn tasks into actions on those objects.

## Procedure

Work through these in order before writing UI code. Deciding layout or tasks first pulls the structure back toward a task menu.

1. Extract objects: take the nouns from the requirements and write down each one's attributes and its relations to the others. Set the verbs aside. Merge synonyms, and fold a noun that is only an attribute of another into that object
2. Give each main object a collection view (list) and a single view (detail). A collection too large to show in full is still a list: show search or filter results, not an empty search form
3. Connect navigation: the root offers the main objects' collections, not a menu of tasks. A collection leads to its items, and an item leads to its related objects
4. Place actions on the selected object, in its single view or on items selected in a list. Creating a new item is an action on its collection. A verb that seems to have no object, such as export, belongs to the object it acts on
5. Stay modeless: the user can leave the current object for another at any point without finishing or cancelling. Use a wizard or a blocking modal only when the steps must complete together, and name that reason
6. Lay out last: decide panes, placement, and visual grouping only now

## Self Check

Answer each before finishing. A "no" calls for changing the structure, not the layout.

- Is the first screen a collection of objects rather than a set of task buttons?
- Does every main object have both a collection view and a single view?
- Can the user go from a list to an item, and from an item to its related objects?
- Does every action appear after its target is selected?
- Can the user move to another object in the middle of any work?

## Reviewing Instead of Writing

Run the self check against the screens. For each "no", report the task-first element (menu entry, wizard, modal, or verb-labeled button) and the object-first structure that replaces it.
