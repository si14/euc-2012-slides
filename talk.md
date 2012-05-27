Hello, my name is Dmitry Groshev and I want to talk about the problem of error
handling. This theme looks pretty straightforward -- in fact, so straightforward
that it's not covered in textbooks as far as I know. Yeah, we all know about
case statement, try/catch, happy path, let it fall and buzzwords like that. But
there is still a problem that looks like that:

    case foo() of
        true ->
            case bar() of
                true -> smth();
                false -> error2()
            end;
        false -> error()
    end

Stuff like this tends to grow and become a total mess of nested cases. What can
we do make this code readable?

Well, we can can hide nested cases in separate functions, but it introduces a
lot of noise and nonsensical function names. It's obviously not real a solution,
it's the hope that the problem will disappear if you don't see it.

(example of code)

You can try to abstract all this logic in a nice validation library that checks
if data conforms to a some sort of scheme. There are pretty decent ones out
there; you can check out Loic's nice library called Sheriff. Here is an example
of it's usage:
(example of code)
What's the problem here? Well, the main one is that any scheme-based validator
is just not powerful enough. Let's pretend that you have an IP and port that
user can type in. So what's an IP? 4 digits, separated by dots? Wrong. There are
IPv6 and short notation and special addresses like 127.0.0.1 and so on and so
forth. Moreover, you can face situation when you need to want to make some ports
available with some IP adresses and not with others. You can continue to
elaborate on your scheme format, but in general it's power will be similar to
the expressiveness of programming language, so there is no point in saying "ok,
we will make this validator and it will solve ALL our validation-related
problems". We still be forced to use nested cases at some point.

So what is the true problem here? In short: we don't have "return". We can't do
implicit branching, we are forced to use only explicit one. Are we? Wrong. We
also have exceptions that give us implicit branching. This is the basis of style
that we all know and love:

    {ok, Data} = foo(Smth)

But what if this matching fails?

(example of matching error)

Ok, we can use catch here and present our error in a more sensible way:

(example of catch)

Look at this code -- let's say that this is a part of some request handler:

    try
        A = list_to_integer(AString),
        B = list_to_integer(BString),
        {ok, {A, B}}
    catch
        error:badarg -> {error, some_integer_was_flawed}

What is the problem here? We can't know what variable was ill-formated. All we
know is that we have some "badarg" exception. And it's sometimes better to know
what error exactly happened -- to show some message to user, for example.

World of functional programming gives one possible solution: monads. I'll make a
brief intro about what it is, just to ensure that everything is clear here. You
can find somewhat more detailed intro in Readme file of Erlando library that we
will cover in a moment.

Let's look at the puprose of comma in our programs:

(two statements)

It's obvious that this is just a syntax, but in some sense it's also an
instruction for something that evaluates our program: please proceede to next
statement, we are done here. You can see that this is an unconditioned jump to
next operation -- again, in some sense. We can make our version of this jump,
but make it conditioned on the result of previous expression:

(example similar to Erlando's)

As you can see, it's pretty messy to write. We definitely don't want to write
things like this. And here is where guys from RabbitMQ team make their magic:
they use parse_transform to transform this mess to quite pretty code:

(example of code with Erlando)

this library is called Erlando and available at Github. You can see that error\_m
thing; what is it exactly? It's the function that controls what exactly will we
expect from statement to decide if we need to proceede or to stop our
computations and return error. error\_m in this case will expect the {ok, smth}
or {error, smth} format that is familiar to all of us. Here is an example of
code that don't use Erlando (it's really messy):

(Erlando's file example)

And here is the one that use Erlando:

(Erlando's file example)

As you can see, the latter is way prettier. Are we done here?

Not yet. There are a couple of problems with this approach, such as an obvious
problem of performance -- we create an anonymous function on each call, after
all. We will talk about performance a little later. It's also doesn't play well
with lists: list itself is another monad and we need a lot of other abstractions
when we combine monads. Haskell has a lot of them, but we don't.
