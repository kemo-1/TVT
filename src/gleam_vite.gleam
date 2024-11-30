import gleam/list
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/event
import sketch/lustre/element

import sketch/size

import sketch
import sketch/lustre as sketch_lustre
import sketch/lustre/element/html

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let assert Ok(cache) = sketch.cache(strategy: sketch.Ephemeral)
  sketch_lustre.node()
  |> sketch_lustre.compose(view, cache)
  |> lustre.application(init, update, _)
  |> lustre.start("#app", Nil)
}

// MODEL -----------------------------------------------------------------------
type Model {
  Model(
    to_do: List(String),
    in_progress: List(String),
    done: List(String),
    new_task: String,
    // Holds the value of the new task being typed
  )
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(Model(to_do: [], in_progress: [], done: [], new_task: ""), effect.none())
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  UpdateNewTask(String)
  AddTask(String)
  DeleteTask(String, String)
}

fn update(model: Model, msg: Msg) {
  case msg {
    UpdateNewTask(value) -> #(Model(..model, new_task: value), effect.none())
    DeleteTask(kanban_block, task) -> {
      case kanban_block {
        "todo" -> {
          let tasks =
            model.to_do
            |> list.filter(fn(t) { t != task })
          #(Model(..model, to_do: tasks), effect.none())
        }
        "in_progress" -> {
          let tasks =
            model.in_progress
            |> list.filter(fn(t) { t != task })
          #(Model(..model, in_progress: tasks), effect.none())
        }
        "done" -> {
          let tasks =
            model.done
            |> list.filter(fn(t) { t != task })
          #(Model(..model, done: tasks), effect.none())
        }

        _ -> #(model, effect.none())
      }
    }

    AddTask(kanban_block) ->
      case kanban_block {
        "todo" -> {
          case model.new_task {
            "" -> #(model, effect.none())
            t -> #(
              Model(..model, to_do: [t, ..model.to_do], new_task: ""),
              effect.none(),
            )
          }
        }
        "in_progress" -> {
          case model.new_task {
            "" -> #(model, effect.none())
            t -> #(
              Model(
                ..model,
                in_progress: [t, ..model.in_progress],
                new_task: "",
              ),
              effect.none(),
            )
          }
        }
        "done" -> {
          case model.new_task {
            "" -> #(model, effect.none())
            t -> #(
              Model(..model, done: [t, ..model.done], new_task: ""),
              effect.none(),
            )
          }
        }
        _ -> #(model, effect.none())
      }
  }
}

// VIEW ------------------------------------------------------------------------
fn block_title() {
  sketch.class([
    sketch.font_size(size.rem(2.0)),
    // Larger text for block titles
    sketch.font_weight("bold"),
    // Makes the title bold
    sketch.margin_("0 0 1.5rem 0"),
    // Adds spacing below the title
    sketch.color("#F7F7F7"),
    // Caribbean Current for title text
    sketch.text_align("center"),
    // Centers the text
    sketch.text_transform("uppercase"),
    // Makes the title uppercase
    sketch.letter_spacing("0.1rem"),
    // Adds spacing between letters for style
  ])
}

fn container() {
  sketch.class([
    sketch.display("flex"),
    sketch.flex_direction("column"),
    sketch.align_items("center"),
    // Centers the content horizontally
    sketch.margin_("auto"),
    // Centers the container
    sketch.padding(size.rem(2.0)),
    // Padding inside the container
    sketch.width(size.percent(90)),
    // Responsive width
    sketch.max_width(size.rem(80.0)),
    // Maximum width for large screens
    sketch.background_color("#001524"),
    // Isabelline background
    sketch.border_radius(size.rem(1.0)),
    sketch.box_shadow("0 8px 16px rgba(0, 0, 0, 0.1)"),
    // Stronger shadow for depth
  ])
}

fn kanban_board_container() {
  sketch.class([
    sketch.overflow_x("auto"),
    // Enables horizontal scrolling
    sketch.white_space("nowrap"),
    // Prevents wrapping of blocks
    sketch.padding(size.rem(1.5)),
    // Adds padding around the scrolling area
    sketch.width(size.percent(100)),
  ])
}

fn kanban_board() {
  sketch.class([
    sketch.display("flex"),
    sketch.flex_direction("row"),
    sketch.gap(size.rem(2.5)),
    // Space between kanban blocks
  ])
}

fn kanban_block() {
  sketch.class([
    sketch.background_color("#2A3D45"),
    // Bright white background for blocks
    sketch.padding(size.rem(2.0)),
    // Padding for content
    sketch.width(size.rem(22.0)),
    // Fixed width for blocks
    sketch.flex_shrink(0.0),
    // Prevents shrinking in flex
    sketch.border_radius(size.rem(0.8)),
    // Rounded corners
    sketch.box_shadow("0 4px 8px rgba(0,0,0,0.1)"),
    // Subtle shadow
    sketch.display("flex"),
    sketch.flex_direction("column"),
    sketch.gap(size.rem(1.5)),
    // Space between tasks inside the block
    sketch.hover([sketch.box_shadow("0 6px 12px rgba(0,0,0,0.15)")]),
  ])
}

fn task() {
  sketch.class([
    sketch.text_align("center"),
    sketch.font_size(size.rem(1.5)),
    sketch.background_color("#F7F7F7"),
    // Task background color
    sketch.border("0.1rem solid #ddd"),
    // Subtle border
    sketch.border_radius(size.rem(0.4)),
    // Rounded corners
    sketch.padding(size.rem(1.0)),
    // Padding inside the task
    sketch.margin_("0.5rem 0"),
    // Space between tasks
    sketch.box_shadow("0 1px 3px rgba(0,0,0,0.1)"),
    // Subtle shadow
    sketch.transition("transform 0.2s ease, box-shadow 0.2s ease"),
    // Smooth hover effect
    sketch.hover([
      sketch.transform("scale(1.02)"),
      // Slight grow on hover
      sketch.box_shadow("0 6px 12px rgba(0,0,0,0.2)"),
      // Prominent shadow on hover
    ]),
    sketch.overflow("hidden"),
    // Prevents text overflow outside the task box
    sketch.text_overflow("ellipsis"),
    // Adds ellipsis for truncated text
    sketch.white_space("normal"),
    // Allows text to wrap to the next line
    // sketch.max_height(size.rem(4.0)),
    // Optional: Set max height to prevent excessively tall tasks
    sketch.line_height("1.8rem"),
    // Adjusts spacing between lines for readability
  ])
}

fn add_task_input() {
  sketch.class([
    sketch.background_color("#F7F7F7"),
    sketch.border("0.1rem solid #ccc"),
    sketch.border_radius(size.rem(0.4)),
    sketch.padding(size.rem(0.8)),
    sketch.margin_("0.5rem 0"),
    sketch.box_shadow("0 1px 3px rgba(0,0,0,0.1)"),
    sketch.font_size(size.rem(1.5)),
  ])
}

fn add_task_button() {
  sketch.class([
    sketch.background_color("#4B8F6A"),
    sketch.font_size(size.rem(1.5)),
    sketch.color("#fff"),
    sketch.border("none"),
    sketch.border_radius(size.rem(0.4)),
    sketch.padding(size.rem(0.8)),
    sketch.margin_("0.5rem 0"),
    sketch.text_align("center"),
    sketch.font_weight("bold"),
    sketch.cursor("pointer"),
    sketch.transition("transform 0.2s ease, background-color 0.2s ease"),
    sketch.hover([
      sketch.background_color("#4B8F8C"),
      sketch.transform("scale(1.05)"),
    ]),
  ])
}

fn delete_task_button() {
  sketch.class([
    sketch.display("inline-flex"),
    sketch.align_items("center"),
    sketch.justify_content("center"),
    sketch.background_color("transparent"),
    sketch.color("#FF5C5C"),
    sketch.border("0.1rem solid #FF5C5C"),
    sketch.border_radius(size.rem(0.5)),
    sketch.padding_("0.3rem 0.6rem"),
    sketch.margin_("0 0 0 0.5rem"),
    sketch.cursor("pointer"),
    sketch.font_size(size.rem(1.0)),
    sketch.font_weight("bold"),
    sketch.transition(
      "background-color 0.3s ease, color 0.3s ease, transform 0.2s ease, box-shadow 0.2s ease",
    ),
    sketch.box_shadow("0 2px 4px rgba(0, 0, 0, 0.1)"),
    sketch.hover([
      sketch.background_color("#FF5C5C"),
      sketch.color("#FFFFFF"),
      sketch.box_shadow("0 4px 8px rgba(0, 0, 0, 0.2)"),
      sketch.transform("scale(1.1)"),
    ]),
    sketch.focus([
      sketch.outline("none"),
      sketch.box_shadow("0 0 0 0.2rem rgba(255, 92, 92, 0.5)"),
    ]),
  ])
}

fn view(model: Model) {
  html.div(container(), [], [
    html.div(kanban_board_container(), [], [
      html.div(kanban_board(), [], [
        html.div(kanban_block(), [], [
          html.div(block_title(), [], [html.text("To Do")]),
          html.input(add_task_input(), [
            attribute.type_("text"),
            attribute.value(model.new_task),
            event.on_input(UpdateNewTask),
          ]),
          html.button(add_task_button(), [event.on_click(AddTask("todo"))], [
            html.text("Add Task"),
          ]),
          element.fragment(
            model.to_do
            |> list.map(fn(task_item) {
              html.div(task(), [], [
                html.text(task_item),
                html.button(
                  delete_task_button(),
                  [event.on_click(DeleteTask("todo", task_item))],
                  [html.text("X")],
                ),
              ])
            }),
          ),
        ]),
        html.div(kanban_block(), [], [
          html.div(block_title(), [], [html.text("In Progress")]),
          html.input(add_task_input(), [
            attribute.type_("text"),
            attribute.value(model.new_task),
            event.on_input(UpdateNewTask),
          ]),
          html.button(
            add_task_button(),
            [event.on_click(AddTask("in_progress"))],
            [html.text("Add Task")],
          ),
          element.fragment(
            model.in_progress
            |> list.map(fn(task_item) {
              html.div(task(), [], [
                html.text(task_item),
                html.button(
                  delete_task_button(),
                  [event.on_click(DeleteTask("in_progress", task_item))],
                  [html.text("X")],
                ),
              ])
            }),
          ),
        ]),
        html.div(kanban_block(), [], [
          html.div(block_title(), [], [html.text("Done")]),
          html.input(add_task_input(), [
            attribute.type_("text"),
            attribute.value(model.new_task),
            event.on_input(UpdateNewTask),
          ]),
          html.button(add_task_button(), [event.on_click(AddTask("done"))], [
            html.text("Add Task"),
          ]),
          element.fragment(
            model.done
            |> list.map(fn(task_item) {
              html.div(task(), [], [
                html.text(task_item),
                html.button(
                  delete_task_button(),
                  [event.on_click(DeleteTask("done", task_item))],
                  [html.text("X")],
                ),
              ])
            }),
          ),
        ]),
      ]),
    ]),
  ])
}
