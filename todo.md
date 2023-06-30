# Features maybe to add in the future
- [ ] file watching (use inotify on unix-like but on windows?)
- [ ] simple testing library based on deno's and maybe taking inspiration from other janet testing libs
- [ ] file locking
- [ ] add multi-method macros
    something like this:
    ```
    (def- my-dispatch-table
      @{'(:string :string :string) (fn [x y z] 1)
           '(:string :string nil) (fn [x y z] 2)
           ...})

    (defn my-multimethod
      [a b c]
      ((in my-dispatch-table [(type a) (type b) (type c)]) a b c))
    ```
    (taken from https://github.com/janet-lang/janet/discussions/581#discussioncomment-279796)
- [ ] add custom type handling based on https://github.com/MikeBeller/janet-abstract
      also consider [this discussion](https://github.com/janet-lang/janet/discussions/581#discussioncomment-285555)
