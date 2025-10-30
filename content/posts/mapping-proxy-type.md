+++
title = "Read-only dictionaries with MappingProxyType"
date = 2025-10-30
updated = 2025-10-30

[taxonomies]
tags = ["python", "stdlib", "programming", "performance", "benchmark"]

[extra]
repo_view = true
comment = true
+++

<!-- more -->

## Socratic dialogue on dictionary mutability

Consider the following Python snippet:

```python
_DEFAULT_CONFIG = {
  "theme": "light",
  "lang": "en-US",
}

# We need a custom config, let's start with reasonable defaults.
custom_config = _DEFAULT_CONFIG
print(custom_config)
# {'theme': 'light', 'lang': 'en-US'}
# Neat! We've got the defaults, but let's switch to dark mode.
custom_config["theme"] = "dark"
print(custom_config)
# {'theme': 'dark', 'lang': 'en-US'}
# Just right.

# Now let's make another custom config.
# Start with defaults again.
another_custom_config = _DEFAULT_CONFIG
print(custom_config)
# {'theme': 'dark', 'lang': 'en-US'}
# Huh, is that right? Shouldn't the default theme be light?
print(_DEFAULT_CONFIG)
# {'theme': 'dark', 'lang': 'en-US'}
# Oops! We've actually clobbered the default configuration.
```

The mutated default configuration will stick around until the module that initializes it gets reloaded,
which is most likely until the next application startup.

You might be thinking:

> This is not how you'd write code for an actual application.

You'd be right, but this is a simplified example. It gets the point across, while still fitting on a napkin.
The mutation issue is just as valid in a complex codebase.

> You can use [`copy.copy`](https://docs.python.org/3/library/copy.html#copy.copy)
> or [`copy.deepcopy`](https://docs.python.org/3/library/copy.html#copy.deepcopy)
> to prevent the mutation of `_DEFAULT_CONFIG`.

Well, kind of. Copying only helps if you remember about it.
One stray assignment can ruin the day – I've seen it happen 😄.

> Can't you wrap the `copy` call in a callable?

Yes, the following is possible:

```python
import copy

_DEFAULT_CONFIG = {
  "theme": "light",
  "lang": "en-US",
}

def get_default_config():
    return copy.deepcopy(_DEFAULT_CONFIG)

config_a = get_default_config()
config_a["i-love"] = "my-cat"
print(config_a)
# {'theme': 'light', 'lang': 'en-US', 'i-love': 'my-cat'}
# Custom changes are in.

print(get_default_config())
# {'theme': 'light', 'lang': 'en-US'}
# Defaults are unchanged.
```

The problem with the above, is that you need every contributor (including yourself) to remember
about never referencing `_DEFAULT_CONFIG` directly. In my experience, that guardrail is bound to fail,
as human memory is fallible.

I believe the implementation should never allow mutating `_DEFAULT_CONFIG` in the first place.
The guardrail needs to be codified into and enforced by the codebase itself.

> Why not use [`typing.Final`](https://docs.python.org/3/library/typing.html#typing.Final) with a linter?

Linters only go as far and do not reach into the runtime. They can lose track of the annotation, if there's enough indirection.

> Ok then, initialize the `_DEFAULT_CONFIG` variable in the scope of the getter function.

We're getting somewhere. Moreover, we can now drop the `copy`, since the config will be initialized on every call anyway.

```python
def get_default_config():
    return {
      "theme": "light",
      "lang": "en-US",
    }

custom_config = get_default_config()
custom_config["theme"] = "dark"
print(custom_config)
# {'theme': 'dark', 'lang': 'en-US'}
# Custom change is in.

print(get_default_config())
# {'theme': 'light', 'lang': 'en-US'}
# Defaults are unchanged.
```

This is a valid solution, but:

- A new dictionary is initialized on every single call of the getter function.
- You need to write an extra wrapper function for every dictionary you want to make (effectively) immutable. This is not a one-size-fits-all.
- What if you need read-only access in most cases, and write access on the rare occasion?
  Initializing the dict on every call seems wasteful in that case.
- There's a standard library solution to this problem, ever since Python 3.3.

## The elegant stdlib solution

Python 3.3 introduced the [MappingProxyType](https://docs.python.org/3/library/types.html#types.MappingProxyType).
It wraps any provided mapping (dict-like objects), while providing a read-only view.

Let's see how that looks like in practice:

```python
import types

_DEFAULT_CONFIG = types.MappingProxyType(
    {
        "theme": "light",
        "lang": "en-US",
    }
)

custom_config = _DEFAULT_CONFIG
# The guardrail is codified and effective in runtime!
custom_config["theme"] = "dark"
# Traceback (most recent call last):
#   File "<python-input-4>", line 2, in <module>
#     custom_config["theme"] = "dark"
#     ~~~~~~~~~~~~~^^^^^^^^^
# TypeError: 'mappingproxy' object does not support item assignment

# Let's get a writable copy.
custom_config = _DEFAULT_CONFIG.copy()
custom_config["theme"] = "dark"
print(custom_config)
# {'theme': 'dark', 'lang': 'en-US'}
# Custom changes are in.

print(_DEFAULT_CONFIG)
# {'theme': 'light', 'lang': 'en-US'}
# Defaults are intact.

# We can read directly from the original, without needing a copy.
print(_DEFAULT_CONFIG["theme"])
# light
```

## Performance benchmark

Talk is cheap, so let's do some timing measurements!

I'm running this on:

- Ryzen 5600G with `performance` governor enabled;
- Linux 6.17.5-arch1-1;
- Python 3.13.7

Important considerations:

- We'll be reading the `"theme"` key for each of the implementations.
- Each implementation will run a million times – that's what's being timed.
- Imports are not timed.
- Variable initializations are not timed, unless they are a core assumption of the implementation (see _getter function_).

### Getter function (writable copy)

```python
import time

def get_default_config():
    # This always returns a fresh, writable dict.
    return {"theme": "light", "lang": "en-US"}

time_start = time.time()
for i in range(10 ** 6):
    get_default_config()["theme"]
time_finish = time.time()

print(time_finish - time_start)
# 0.12346076965332031
```

Approximately 123 ms, just below 1/8th of a second.

### MappingProxyType.copy (writable copy)

Let's try the same, but with the [MappingProxyType](https://docs.python.org/3/library/types.html#types.MappingProxyType):

```python
import copy
import time
import types

_DEFAULT_CONFIG = types.MappingProxyType(
    {
        "theme": "light",
        "lang": "en-US",
    }
)

time_start = time.time()
for i in range(10 ** 6):
    # Writable copy of the underlying dict.
    _DEFAULT_CONFIG.copy()["theme"]
time_finish = time.time()``

print(time_finish - time_start)
# 0.11182737350463867
```

111 ms is already faster than the previous approach, while also providing a writable copy.

### MappingProxyType (read-only)

Let's time read-only access:

```python
import copy
import time
import types

_DEFAULT_CONFIG = types.MappingProxyType(
    {
        "theme": "light",
        "lang": "en-US",
    }
)

time_start = time.time()
for i in range(10 ** 6):
    # Read-only access
    _DEFAULT_CONFIG["theme"]
time_finish = time.time()

print(time_finish - time_start)
# 0.05148005485534668
```

Read-only access times at ~51 ms, which is over twice as fast, in comparison to the `get_default_config` implementation.

### Summary

| Implementation                    | time \[ms\] |
| --------------------------------- | ----------- |
| Getter function (always writable) | 123         |
| MappingProxyType (writable copy)  | 111         |
| MappingProxyType (read-only)      | 51          |

Overall these are not drastic differences (think many orders of magnitude).
The key takeaway here are the process improvements and safety guardrails.

Having said that, if you're dealing with a similar case and are **reading** an item particularly frequently,
you might actually see observable performance benefits from using the [MappingProxyType](https://docs.python.org/3/library/types.html#types.MappingProxyType).
