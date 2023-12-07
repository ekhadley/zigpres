<img src=".\assets\zig.png" alt="zig_logo" width="600" justify-center/>

### Zig Language

Zig is “A general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software”. It aims to be pure and simple, but also drop in/take over existing C/Cpp seamlessly, and smooth the rough edges of these languages with some new ideas.

**First appeared** 2017?  
**Designer Andrew** Kelley  
**Notable Versions** It's only 0.11 …  
**Recognized for** not being Rust  
**Notable uses** maintaining existing codebases, compiling/cross compiling C  
**Tags** compiled, statically-typed, metaprogramming,  memory managed  
**Six words or less** “C, but with the problems fixed”  

The Zig project is perhaps not best described as a “language”. Among the project's major endeavors is to seamlessly integrate with C codebases, which requires a bit more than just a language. Zig comes with a whole build system. A toolchain, and compiler. You can compile C with it, translate Zig into C, or C into Zig! Zig the language is interesting and deserving of merits on its own, but its supporting cast are essential and central to the Zig mission of superseding C while working with it seamlessly. Here I will mainly cover features of the language itself, apart from the C interop capabilities and toolchain/compiler capabilities.

It should be mentioned that this project is early, only coming up on version 1.0. Some of the features I mention
are actually planned features, possibly liable to change or exclusion from later versions. I am also not experienced in systems languages; during my testing I encountered many error messages I found odd or cryptic. I suspect some of these were not errors that “should” be happening (that would not happen in a later, more mature version of Zig), but it is hard for me to tell.

In Zig, errors are first class citizens, as are types. Passing around types and errors like any other value are essential parts of ensuring code is correct, and handles errors gracefully. Perhaps Zig’s most mentioned feature is `comptime`: a keyword that allows arbitrary code to be executed at compile time. It lets us reassure the compiler that a type passed as a function argument will be known later. This feature, along with `var`\\`const` for denoting mutability, and other design decisions lets Zig be expressive while still aggressivley optimizing during compilation.

Zig holds a more pragmatic take on safety (and correctness in general) than Rust. Zig appears to respect the fact that people are lazy, and while a select few programmers seem to enjoy dodging their borrow checkers, if you have to do extra work to make your program safe, a lot of people just won’t do it. Where Rust makes it harder to do things wrong, Zig instead makes it easier to do things right. C is notable for, among many other things, containing an entire arsenal with which to shoot yourself in the foot (or feet). Many of these foot guns revolve around manually allocating and freeing memory. Zig’s allocators are a novel take on management that makes the easiest way to do things the correct way. 

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

There is little to note, besides the printing syntax. `std.log()` is considered the proper way to report to the console, so `print` is relegated to debug. `print` automatically behaves like a formatted print. The second argument is an anonymous (literal) struct, (which is what we mean by a tuple in Zig) which are useful for bundling up arguments. Tuples can be iterated over, and anonymous fields (like used in the print statement) can be accessed like `@"0"`, `@"1"`, or posess names, which we show later.

### Word Permutations

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
Our Heap's Algorithm example program provides a good place to discuss arrays, slices, and strings. In Zig, `[n]T` is an array of type `T` containing `n` elements. `[]T` gives us a slice. A slice can be generated from an existing array like: `array[lower..upper]`. When created like this, the slice does not copy the underlying memory. `[*]T` is called a 'multi-item pointer'. It means it can act like a pointer to a single value, but will also allow us to index it like a sequence type. A slice `[]T` is more or less a `[*]T` paired with an integer to denote length. Using an allocator to free memory gives us a slice by default. Coercion between arrays and slices is subtle in Zig. The general rule is that when a slice's bounds are known at compile time, we actually get a pointer that directs us to some points in the underlying array. To demonstrate some of what Zig asks of us concerning types, lets ask: "zig" seems like a string. What if we just give the literal to the function directly?  
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
- `std.heap.c_allocator`: For those who like to live dangerously: extremely fast, but (because of) essentially 0 safety checks.
- `std.heap.ArenaAllocator()`: Takes another allocator as argument. Use this to make multiple instances of that given allocator type. The arena allocator is able to free all memory allocated by its children with one call.

Freeing and writing a string with the `GeneralPurposeAllocator` looks like this:
```zig
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{.verbose_log=true}){};
    const alloc = gpa.allocator();

    const mem = try alloc.alloc(u8, 10);
    defer alloc.free(mem);
    
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
PS D:\wgmn\zigpres> D:\zig\zig.exe run .\alloc.zig
info(gpa): small alloc 10 bytes at u8@28ac8970000
0123456789☺☻♥♦♣♠, []u8, 10
```
Notice the new occurence of a literal struct for instantiating our `std.heap.GeneralPurposeAllocator`. This time we are using named fields where we assign values, optionally ovewriting the defaults. Some options for `gpa` are verbose logging (turned on here), `.safety`, `.never_unmap`, and `.enable_memory_limit`, etc, to tune the safety/performance characteristics.

A very common Zig pattern is an `alloc` followed by a `defer` freeing the memory. A statement or block preceded by `defer` will not be run until the program execution leaves the block the defer was typed in. Multiple `defer`s in a block will be executed in reverse order. What this defer pattern allows us to do is avoid if/else chains for handling and freeing memory many lines away from where it is allocated. It simplifies the task of safe handling. Another common pattern is passing our allocator to a function. The function uses the allocator to allocate and then defer whatever it needs, and when we return from the function we know that memory will be safely freed. I excluded it from our word permutations example to highlight literals/arrays, but reading from command line args looks like this:
```zig
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();

    while (args.next()) |arg| {
        print("{s}, ", .{arg});
    }
}
```
We create an allocator, give it the characteristics we desire, then pass that allocator to subsequent functions which need to allocate, letting us easily change the memory handling profile of our code and external/builtin functions by specifying behavior in one spot. And don't forget the `defer` statement here, ensuring that the memory allocated for our args is freed automatically when we exit the scope where it is used.

## Comptime!
`Comptime` is perhaps Zig's most well known and highly praised feature. Comptime allows us to execute arbitrary code at compile time. It is Zig's iteration on C's macros, which plague larger and older codebases, using their own preprocessor-mini-language, and which make debugging notoriously difficult. Consider the following function for making 2D arrays:
```zig
pub fn matrix(alloc: std.mem.Allocator, comptime n: usize, comptime T: type) ![n][n]T {
    var m: [n][n]T = try alloc.alloc([n]T, n);

    const e: T = 0;
    for (0..n) |j|{
        for (0..n) |i| {
            m[j][i] = e;
        }
    }
    return m;
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const m = try matrix(alloc, 3, f64);

    print("{d}\n", .{m});
}
```
Output:
```zig
PS D:\wgmn\zigpres> D:\zig\zig.exe run .\comp.zig
{ { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } }
```
Note the use of `comptime` for the arguments `n` and `T`. Passing a type as a comptime parameter is a common idiom in Zig for making type-generic objects. As the name suggests, these arguments are collected at compile time, instead of runtime. Attempting to do things like this in C; declaring an array of a length given by a variable, even a constant one, will be met with resistance. Attempting to describe types with non-`comptime` variables is similairly disallowed in Zig. `comptime` is how we safely tell the compiler, 'don't worry, I'll give you this later'. The compiler can deduce that, when `matrix` is used in `main`, the comptime parameters `n` and `T` are 3 and `f64`. So the function that actually gets compiled, and the one that actually gets run at runtime is indistinguishable from if we wrote:
```zig
pub fn matrix(alloc: std.mem.Allocator) ![3][3]f64 {
    var m: [3][3]f64 = try alloc.alloc([3]f64, 3);

    const e: f64 = 0;
    for (0..3) |j|{
        for (0..3) |i| {
            m[j][i] = e;
        }
    }
    return m;
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const m = try matrix(alloc);

    print("{d}\n", .{m});
}
```
, with all the `comptime` parameters replaced with the values we passed. If we called matrix again with different comptime parameters, say `n=6`, and `T=u321` (yes, an unsigned 321 bit integer), then a whole new function is compiled, looking like the above but with all `3`'s and `f64`'s replaced accordingly, and that version gets ran at runtime. Note that we don't need to just pass literals for `comptime` arguments; any binding whose value can be deduced at compile time will do. There are several considerations for what can be properly run at compile time, and what can be passed as a comptime argument, but the basic case I just showed is extremely common, and a powerful pattern for intuitively and concisely creating safe and flexible data types and functions.  
Zig compiling optimizations can also include trimming if/switch branches. If a `comptime` arg is used a condition, then we know at comptime if the condition is true, so we can only compile the branch we know will be taken and ignore the rest. Something like:
```zig
pub fn print_uints(comptime T: type, x: T) void {
    switch (T) {
        u16 => print("x is a u16 = {d}\n", .{x}),
        u32 => print("x is a u32 = {d}\n", .{x}),
        u64 => print("x is a 64 = {d}\n", .{x}),
        f16,f32,f64,f128 => print("hey, this isnt a uint..\n", .{}),
        else => {},
        }
}
pub fn main() !void {
    // this version compiles like `pub fn print_uints(x:u32)void {print( "x is a u32 = {d}\n", .{x}) }`
    print_uints(u32, 1000); 
    // and this one like `pub fn print_uints(x:f128)void {print( "hey, this isnt a uint..\n", .{}) }`
    print_uints(f128, 10.5);
}
```
## Errors
As stated before, errors in zig are first-class citizens. The error handling system is simple and intuitive. We do not throw exceptions in Zig; errors within a function become the returned value of the calling function. Consider the following:
```zig
const std = @import("std");
const print = std.debug.print;

const medianError = error{noMiddleElem, emptyArray};

pub fn median(comptime T: type, comptime n: usize, arr: [n]T) medianError!T {
    if (n == 0) { return medianError.emptyArray; }
    if (n % 2 == 0) { return medianError.noMiddleElem; }
    return arr[n/2];
}

pub fn main() !void {
    const a = [_]f32{4, 5, 6, 7, 8};
    
    const mid= try median(f32, a.len, a);
    print("the median of {d} is {}\n", .{a, mid});
}
```
Instead of panicking or 'throwing' an error: our functions *return* errors, which are really just special kinds of enums. The expression `medianError!T` specifies an 'error union': it couples the possible errors with the 'intended' return type. Saying `!T` is the same as using the keyword `anyerror!T`. Because `median` is stated to possibly return errors, we must call it with a `try`. What `try` says is that we will attempt to call the function and proceed normally if it does not error, or make the error the return of the calling function. This is why `main` must state its return type as `!void`, despite lacking any error returns.  
If we attempt to set the main function's return type as just `void`, we fail to compile:
```zig
errors.zig:16:20: error: expected type 'void', found 'error{noMiddleElem,emptyArray}'
    const mid= try median(f32, a.len, a);
                   ^~~~~~~~~~~~~~~~~~~~~~~~~
errors.zig:13:15: note: function cannot return an error
```
The compiler sees that we are `try`ing to run our median function, meaning we know errors are a possibility, but main is not prepared to return anything but `void`. A side effect of our comptime length `n`, is that we actually know at compile time, not runtime, what return types are possible from median. If we only state `median`'s return type as T, `main`'s as `void` and get rid of the `try`, then as is, our compiler will create a version of `median` that excludes the error returns as a possibility, and all is good. If we then changed the length of `a` to be an even number or 0, becuase `n` is `comptime`, before we even run the function, Zig knows will error, and that our stated return types are inappropriate.  

If we wish to handle errors more specifically, without breaking out to the parent function, we have `catch`:
```zig
pub fn main() !void {
    const b = [_]u8{5, 11, 12, 12, 11, 5};
    const bmid = median(u8, b.len, b) catch |err| {
        print("{s} has no median!!! [failed with {}]", .{b, err});
        return;
    };
    print("end of main: {}\n", .{bmid});
}
```
We make a string `b` with no median. The catch syntax lets us conveniently express the common code phrase 'assign if I can, otherwise let me check the error'. The above outputs:
```zig
PS D:\wgmn\zigpres> D:\zig\zig.exe run .\errors.zig
♣♂♀♀♂♣ has no median!!! [failed with error.noMiddleElem]
```
The double `|` is called a payload capture, which you may recognize from the for loop syntax. If you are still confused about `try`, it is really just a shortcut for a catch and capture: `try {}` = `{} catch |err| return err`. Notice that we choose to return `void` after catching the error. We have no obligation to return caught errors. Returning the error itself would cause a proper thread panic.  


### Unions, Enums, Structs, oh my
Zig contains the big 3 of composite data types, present in most low level languages. They are designed to synergize powerfully with Zig's types, comptime, and error handling facilities. We begin with the simplest type: enums.
##### Enums
Enums work largely how you might expect from other languages. They are collections of fields with automatic or reassignable integer (by default) values:
```zig
const std = @import("std");
const print = std.debug.print;

const student = enum(u32){ freshman, sophomore, junior, senior, supersenior=1_000_000, hypersenior };

pub fn main() !void {
    print("student: {}, {}, {}, {}\n", .{student, @TypeOf(student), @TypeOf(student.sophomore), @intFromEnum(student.sophomore)});
    
    const ethan = student.senior;
    print("ethan: {}, {},  {}\n", .{ethan, @TypeOf(ethan), @intFromEnum(ethan)});
    
    const nahte = student.supersenior;
    print("nahte: {}, {},  {}\n", .{nahte, @TypeOf(nahte), @intFromEnum(nahte)});

    const xX_EtHaN_Xx = student.hypersenior;
    print("xX_EtHaN_Xx: {}, {},  {}\n", .{xX_EtHaN_Xx, @TypeOf(xX_EtHaN_Xx), @intFromEnum(xX_EtHaN_Xx)});
}
```
Output:
```zig
PS D:\wgmn\zigpres> D:\zig\zig.exe run .\enum.zig
student: enum.student, type, enum.student, 1
ethan: enum.student.senior, enum.student,  3
nahte: enum.student.supersenior, enum.student,  1000000
xX_EtHaN_Xx: enum.student.hypersenior, enum.student,  1000001
```
We see here that enum qualifies as a new `type`. Also interestingly, we see that values of an enum coerce to the superclass: `@TypeOf(student.sophomore) == @TypeOf(student)`. Values all have an ordinal value, starting at 0 and counting . The `(u32)` signifier is not necessary unless we are reassigning the ordinal value of one of the values like we do with `student.supersenior`. We are only allowed to reassign values as integers, and we cannot assign a value to one already generated (like trying to assign supersenior's value to 0->3). And if we assign one value but not the next, the autoincrement picks up from the previous, giving us hypersenior's value.  
There are several interesting properties of enums; they can contain methods, var and const variables, coercion rules, but they are excluded for brevity.
#### Structs
Structs, unlike enums, store a fixed (comptime known) number of fields. Structs can be declared as types, or instantiated anonymously, as we have seen in several places. Structs's fields must be declared with a type they will accept, but not with `var`\\`const`. Consider the `car` struct below:
```zig
const std = @import("std");
const print = std.debug.print;

const failedToDrive = error{noTiresError, negativeHorsepowerError};

const car  = struct{
    year: u32,
    hp: u32,
    ntires: u32,
    name: []u8,
    alloc: std.mem.Allocator = std.heap.page_allocator,

    pub fn drive(self: *const car) !void {
        if(self.ntires == 0) { return failedToDrive.noTiresError; }
        if(self.hp < 0) { return failedToDrive.negativeHorsepowerError; }

        var out = try self.alloc.alloc(u8, self.hp+3);
        defer self.alloc.free(out);

        out[0] = 'v';
        out[1] = 'r';
        for (0 .. self.hp+1) |i| {
            out[i+2] = 'o';
        }
        out[self.hp+2] = 'm';

        print("the {s} goes {s}\n", .{self.name, out});
    }
};

pub fn main() !void {
    var name = "accord".*;
    const mycar = car{.year = 2005, .hp = 35, .ntires = 3, .name = &name};
    mycar.drive() catch |err| {
        switch (err) {
            failedToDrive.noTiresError => print("{s} cannot drive without tires\n", .{mycar.name}),
            failedToDrive.negativeHorsepowerError => print("{s} has negative horsepower!. refer to driveBackwards()\n", .{mycar.name}),
            else => print("unknown error\n", .{}),
        }
        return;
    };
}
```
Output:
```zig
PS D:\wgmn\zigpres> D:\zig\zig.exe run .\struct.zig
the accord goes vrooooooooooooooooooooooooooooooooooom
```
We have several features on display here. We declare our struct with the fields in the body: no init function. When initializing a `car` struct, we must pass all required fields by name or with order inferred. Structs allow default fields, as shown with the `std.heap.page_allocator`, which we don't need to provide (but can) on instantiation. We created a custom error type, and then handle the errors with the previously mentioned `switch` statement in our main.

#### Unions
Not covered due to lack of time :/

## Wrap Up
- While Zig is still in it's early stages, it is developing rapidly. The build system is already quite mature. It takes very little effort to get up and running in Zig
- Zig is planned to have a fully fledged package manager.
- A goal of Zig is to remain small, pragmatic, and pure, avoiding to add complexity to the language where it can just aska  bit more of the programmer (anti Cpp style)
- We can use comptime to run generic code at compile time, and tell the compiler that an argument will be known when it is called, allowing powerful generic types and functions, without macros or great complexity.
- Allocators allow us to safely be lazy, and dynamically choose the memory usage profile of code we, or others, wrote.
- Errors are types! Errors are values our function must be ready to return in the form of a union. Error catching is intuitively done with `try` or `catch`
- Structs work well with `comptime ` types to make generic and effecient data structures
- C is dead. Long live Zig.




