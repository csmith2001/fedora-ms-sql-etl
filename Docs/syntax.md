### Positive Lookbehind (Perl-REGEX)

```Perl
(?<="text")
```

### Positive Lookahead (Perl-REGEX)

```Perl
(?="text")
```

## awk

This can get real fun, awk can be used with print and printf and can be sent variables from bash using:

```Shell
echo "hello" | awk -v user="$name" '{printf "%s: %s\n", user, $1}'
```

```Shell
MICROSOFT_SIGNING_KEY=$(
    curl -fsSL "$MICROSOFT_REPO" |
    awk -F= '/^gpgkey=/{print $2}'
)
```

* `-F=` means use `=` as the field seperator
  * `$1` becomes gpgkey
  * `$2` becomes url
* `/^gpgkey=/` is a REGEX pattern to match
* `{print $2}` prints the second field
