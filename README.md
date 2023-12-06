<img src=".\assets\zig.png" alt="zig_logo" width="600" justify-center/>

### Zig Language

Zig is “A general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software”. It aims to be pure and simple, but also drop in/take over existing C/Cpp seamlessly, and smooth the rough edges of these languages with some new ideas.

**First appeared** 2017?  
**Designer Andrew** Kelley  
**Notable Versions** It's only 0.11 …  
**Recognized for** being a new systems language that isn’t Rust  
**Notable uses** maintaining existing codebases, compiling/cross compiling C  
**Tags** compiled, statically-typed, metaprogramming,  memory managed  
**Six words or less** “C, but with the problems fixed”, “Maintain it with Zig”  

The Zig project is perhaps not best described as a “language”. Among the project's major endeavors is to seamlessly integrate with C codebases, which requires a bit more than just a language. Zig comes with a whole build system. A toolchain, and compiler. You can compile C with it, translate Zig into C, or C into Zig! Zig the language is interesting and deserving of merits on its own, but its supporting cast are essential and central to the Zig mission of superseding C while working with it seamlessly. Here I will mainly cover features of the language itself, apart from the C interop capabilities and toolchain/compiler capabilities.

It should be mentioned that this project is early, coming up on version 1.0. Some of the features I mention
are actually planned features, possibly liable to change or exclusion from later versions. I am also not experienced in systems languages; during my testing I encountered many error messages I found odd or cryptic. I suspect some of these were not errors that “should” be happening (that would not happen in a later, more mature version of Zig), but it is hard for me to tell.

In Zig, errors are first class citizens, as are types. Passing around types and errors like any other value are essential parts of ensuring code is correct, and handles errors gracefully. Perhaps Zig’s most mentioned feature is `comptime`: a keyword that allows arbitrary code to be executed at compile time. It lets us reassure the compiler that a type passed as a function argument will be known later. This feature, along with `var`\\`const` for denoting mutability, and other design decisions lets Zig be expressive while still aggressivley optimizing during compilation.

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

There is little to note, besides the printing syntax. `std.log()` is considered the proper way to report to the console, so `print` is relegated to debug. `print` automatically behaves like a formatted print. The second argument is an anonymous struct, (acting like a tuple) that bundles up all our values to be formatted.

### Heap's Algorithm

```zig
const std = @import("std");
const print = std.debug.print;

pub fn swap(a: *u8, b: *u8) void {
    const tmp: u8 = a.*;
    a.* = b.*;
    b.* = tmp;
}

pub fn heaps(word: []u8, n: usize) void {
    if (n == 0) {
        print("{s}\n", .{word});
    } else {
        for (0..n) |i| {
            heaps(word, n - 1);
            if (n % 2 == 0) {
                swap(&word[0], &word[n]);
            } else {
                swap(&word[i], &word[n]);
            }
        }
        heaps(word, n - 1);
    }
}

pub fn main() void {
    var word = "zig".*;
    heaps(&word, word.len-1);
}
```

Output:

```zig
PS D:\wgmn\zigpres> D:\zig\zig.exe run .\hello.zig
zig
izg
gzi
zgi
igz
giz
```  
### Arrays/Slices  
Our Heap's Algorithm example program provides a good place to discuss arrays, slices, and strings. In Zig, `[n]T` is an array of type `T` containing `n` elements. `[]T` gives us a slice. A slice can be generated from an existing array like: `array[lower..upper]`. When created like this, the slice does not copy the underlying memory. Using an allocator to free memory gives us a slice by default. The difference in Zig is less pronounced than Go. The general rule is that when a slice's bounds are known at compile time, we actually get a pointer that directs us to some points in the underlying array. To demonstrate some of what Zig asks of us concerning types, lets ask: "zig" seems like a string. What if we just give the literal to the function directly?  
```zig
pub fn main() void {
    var word = "zig";
    heaps(word, word.len-1);
}
```   
Gives us:  
```zig
PS D:\wgmn\zigpres> D:\zig\zig.exe run .\hello.zig
hello.zig:38:11: error: expected type '[]u8', found '*const [3:0]u8'
    heaps(word, word.len-1);
          ^~~~
hello.zig:38:11: note: cast discards const qualifier
hello.zig:11:20: note: parameter type declared here
pub fn heaps(word: []u8, n: usize) void {
                   ^~~~
```  
We get a complaint from the compiler. Zig has no proper String type. What is usually meant by a 'string' is a sequence (array or slice) of `u8`: unsigned 8 bit integers. A 'string literal', declared like `word` from our permutations example, is an array. `@TypeOf(word) == *const [3:0]u8`: an immutable pointer, pointing to a length-3 null terminated (thats the 0) array of bytes. Note that despite declaring with `var`, we get a `*const`, a 'constant pointer', not a pointer to a constant (`const *T`) nor a pointer to an array of constant values (`const *[_]T`). I find the difference between a pointer and an array to be subtle: our permutation function expects a `[]u8` (u8 slice, essentially a pointer and a length). It doesn't seem to like that we gave it an array (compile-time-known length), located by a `*const` instead of a normal pointer. So let's attempt to coerce our type. If we pass instead the data pointed to by word: `word.*`, We are presented with the helpful: ```error: array literal requires address-of operator (&) to coerce to slice type '[]u8'```.  Which is why we choose to assign like `var word = "zig".*` , and call like `heaps(&word, word.len - 1)`. Assigning to a literal gives us a `*const` to an array, so we have to reference then dereference before Zig is comfortable coercing our pointer into a slice.

## Allocators  
Allocators are Zig's main method of ~manual memory management. Allocators are used to allocate memory, and greatly simplify the process of keeping track of and freeing your memory. There are several kinds of allocators and strategies one can employ using them:
- `std.heap.page_allocator`: A common and generic allocator. Asks the OS for large chunks of memory, even for small allocations. Talking to the OS makes this allocator relatively slow.
- `std.heap.FixedBufferAllocator`: Does not use the heap, allocates to a fixed buffer.
- `std.heap.GeneralPurposeAllocator`: Zig's general purpose allocator. Designed to be safe and fast. Checks for use of freed memory, memory leaks, etc. 
- `std.heap.c_allocator`: For those who like to live dangerously: extremely fast, but with essentially 0 safety checks.
-`std.heap.ArenaAllocator()`: Takes another allocator as argument, and can use it to make multiple instances of that given allocator type. The Arena allocator is able to free all memory allocated by its children with one call.

Freeing and writing a string with the `GeneralPurposeAllocator` looks like this:
```zig
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{.verbose_log=true}){};
    const alloc = gpa.allocator();

    const mem = try alloc.alloc(u8, 10);
    
    var i: u8 = 0;
    for (0..mem.len) |j| {
        mem[j] = i;
        print("{}", .{i});
        i += 1;
    }
    print("{s}, {}, {}", .{mem, @TypeOf(mem), mem.len});
}
```
Output:
```zig
PS D:\wgmn\zigpres> D:\zig\zig.exe run .\ex.zig
info(gpa): small alloc 10 bytes at u8@28ac8970000
0123456789☺☻♥♦♣♠, []u8, 10
```
Note how we instantiated `gpa`. We passed an empty tuple to 