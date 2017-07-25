


  # todoList package
  if (requireNamespace("todoList", quietly = TRUE)) {
    if (file.exists("./todo.csv")) {
      todo <- todoList::TodoList$new(file = "./todo.csv")
    } else {
      todo <- todoList::TodoList$new()
    }
  }


.Last <- function() {
  if (requireNamespace("todoList", quietly = TRUE) &&
      exists("todo") &&
      is(todo, "TodoList"))
         todo$write.csv(file = "./todo.csv")

    }

