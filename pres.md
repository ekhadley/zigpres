<img src=".\assets\zig.png" alt="drawing" width="500"/>

### Zig Language

Zig is “A general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software”. It aims to be pure and simple, but also drop in/take over existing C/Cpp seamlessly, and smooth the rough edges of these languages with some new ideas.

**First appeared** 2017?
**Designer Andrew** Kelley
**Notable Versions** It's only 0.11 …
**Recognized for** being a new systems language that isn’t Rust
**Notable uses** maintaining existing codebases, compiling/cross compiling C
**Tags** compiled, statically-typed, metaprogramming,  memory managed
**Six words or less** “C, but with the problems fixed”, “Maintain it with Zig”

Zig is perhaps not best described as a “language”. Among Zig’s major endeavors is to seamlessly integrate with C codebases, which requires a bit more than just a language. Zig comes with a whole build system. A toolchain, and compiler. You can compile C with it, translate Zig into C, or C into Zig! Zig the language is interesting and deserving of merits on its own, but its supporting cast are essential and central to the Zig mission of superseding C while working with it seamlessly. Here I will mainly cover features of the language itself, apart from the C interop capabilities and toolchain/compiler capabilities.

It should be mentioned that this project is early, coming up on version 1.0. Some of the features I mention
are actually planned features, possibly liable to change or exclusion from later versions. I am also not experienced in systems languages; during my testing I encountered many error messages I found odd or cryptic. I suspect some of these were not errors that “should” be happening (that would not happen in a later, more mature version of Zig), but it is hard for me to tell.

In Zig, errors are first class citizens, as are types. Passing around types and errors like any other value are essential parts of ensuring code is correct, and handles errors gracefully. Perhaps Zig’s most mentioned feature is `comptime`: a keyword that allows arbitrary code to be executed at compile time, and lets us reassure the compiler that a type passed as a function argument will be known later, allowing clean type-generic code and data structures and strong compiler optimizations.

Zig holds a more pragmatic take on safety (and correctness in general) than Rust. Zig appears to respect the fact that people are lazy, and while a select few programmers seem to enjoy fighting their borrow checkers, if you have to do extra work to make your program safe, a lot of people just won’t do it. Where Rust makes it harder to do things wrong, Zig instead makes it easier to do things right. C is notable for, among many other things, containing an entire arsenal with which to shoot yourself in the foot (or feet). Many of these foot guns revolve around manually allocating and freeing memory. Zig’s allocators are a novel form of management that makes the simplest way to do something the correct way. 

My overview will begin with the classic examples, then cover arrays/slices/strings, comptime, try/errors, and allocators/defer.

## Hello Zig

Our traditional pythagorean triple program:

```zig
const std = @import("std"); // we import 
const print = std.debug.print;

pub fn main() void {
    for (1..40) |c| { // .. for exclusive ranges. I don't think theres an inclusive yet? easy to emulate.
        for (1..c) |b| {
            for (1..b) |a| {
                if (a * a + b * b == c * c) {
                    print("{d}**2 + {d}**2 = {d}**2\n", .{ a, b, c });
                }
            }
        }
    }
}
```

There is little to note, besides the printing syntax. `std.log()` is considered the proper way to report to the console, so `print` is relegated to debug. `print` automatically behaves like a formatted print. The second argument is an anonymous struct, (acting like a tuple) that holds all our values to be formatted.

### Heap's Algorithm:

```zig

```
