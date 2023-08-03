
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Rix: Reproducible Environments with Nix

## Installation

You can install the development version of rix from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("b-rodrigues/rix")
```

If you are on Windows, you need the windows subsystem for linux 2 (WSL2)
to run Nixpkgs. Easiest is to get your R system set up via Nixpkgs, and
then install {rix}. Feel free to check out the instructions at the
bottom for further details on Windows.

## Introduction

<!-- badges: start -->

[![R-CMD-check](https://github.com/b-rodrigues/rix/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/b-rodrigues/rix/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`{rix}` is an R package that provides functions to help you setup
reproducible development environments that contain all the required
packages that you need for your project. This is achieved by using the
Nix package manager that you must install separately. The Nix package
manager is extremely powerful: with it, it is possible to work on
totally reproducible development environments, and even install old
releases of R and R packages. With Nix, it is essentially possible to
replace `{renv}` and Docker combined. If you need other tools or
languages like Python or Julia, this can also be done easily. Nix is
available for Linux, macOS and Windows.

## The Nix package manager

Nix is a piece of software that can be installed on your computer
(regardless of OS) and can be used to install software like with any
other package manager. If you’re familiar with the Ubuntu Linux
distribution, you likely have used `apt-get` to install software. On
macOS, you may have used `homebrew` for similar purposes. Nix functions
in a similar way, but has many advantages over classic package managers.
The main advantage of Nix, at least for our purposes, is that its
repository of software is huge. As of writing, it contains more than
80’000 packages, and the entirety of CRAN is available through Nix’s
repositories. This means that using Nix, it is possible to install not
only R, but also all the packages required for your project. The obvious
question is why use Nix instead of simply installing R and R packages as
usual. The answer is that Nix makes sure to install every dependency of
any package, up to required system libraries. For example, the `{xlsx}`
package requires the Java programming language to be installed on your
computer to successfully install. This can be difficult to achieve, and
`{xlsx}` bullied many R developers throughout the years (especially
those using a Linux distribution, `sudo R CMD javareconf` still plagues
my nightmares). But with Nix, it suffices to declare that we want the
`{xlsx}` package for our project, and Nix figures out automatically that
Java is required and installs and configures it. It all just happens
without any required intervention from the user. The second advantage of
Nix is that it is possible to *pin* a certain *revision* for our
project. Pinning a revision ensures that every package that Nix installs
will always be at exactly the same versions, regardless of when in the
future the packages get installed.

## Rix workflow

The idea of `{rix}` is for you to declare the environment you need,
using the provided `rix()` function, which in turn generates the
required file for Nix to actually generate that environment. You can
then use this environment to either work interactively, or run R
scripts. It is possible to have as many environments as projects. Each
environment is isolated (or not, it’s up to you).

The main function of `{rix}` is called `rix()`. `rix()` has several
arguments:

- the R version you need for your project
- a list of R packages that your project needs
- an optional list of additional software (for example, a Python
  interpreter, or Quarto)
- an optional list with packages to install from Github
- whether you want to use RStudio as an IDE for your project (or VS
  Code, or another environment)
- a path to save a file called `default.nix`.

For example:

``` r
rix(r_ver = "current", r_pkgs = c("dplyr", "chronicler"), ide = "rstudio")
```

The call above writes a `default.nix` file in the current working
directory. This `default.nix` can in turn be used by Nix to build an
environment containing RStudio, the current (or latest) version of R,
and the latest versions of the `{dplyr}` and `{chronicler}` packages. In
th case of RStudio, it actually needs to be installed for each
environment. This is because RStudio changes some default environment
variables and a globally installed RStudio (the one you install
normally) would not recognize the R installed in the Nix environment.
This is not the case for other IDEs such as VS code or Emacs. Another
example:

``` r
rix(r_ver = "4.1.0", r_pkgs = c("dplyr", "chronicler"), ide = "code")
```

This call will generate a `default.nix` that installs R version 4.1.0,
with the `{dplyr}` and `{chronicler}` packages. Because the user wishes
to use VS Code, the `ide` argument was set to “code”. This installs the
required `{languageserver}` package as well, but unlike
`ide = "rstudio"` does not install VS Code in that environment. Users
should instead use the globally installed VS Code.

### default.nix

The Nix package manager can be used to build reproducible development
environments according to the specifications found in a file called
`default.nix`. To make it easier for R programmers to use Nix, `{rix}`
can be used to write this file for you. Once this file has been written,
go to where you chose to write it (ideally in a new, empty folder that
will be the root folder of your project) and use the Nix package manager
to build the environment. Call the following function in a terminal:

    nix-build

Once Nix done building the environment, you can start working on it
interactively by using the following command:

    nix-shell

You will *drop* in a Nix shell. You can now call the IDE of your choice.
For RStudio, simply call:

    rstudio

This will start RStudio. RStudio will use the version of R and library
of packages from that environment.

### Running programs from an environment

You could create a bash script that you put in the path to make this
process more streamlined. For example, if your project is called
`housing`, you could create this script and execute it to start your
project:

    !#/bin/bash
    nix-shell /absolute/path/to/housing/default.nix --run rstudio

This will execute RStudio in the environment for the `housing` project.
If you use `{targets}` you could execute the pipeline in the environment
by running:

    nix-shell /absolute/path/to/housing/default.nix --run Rscript -e 'targets::tar_make()'

It’s possible to execute the pipeline automatically using a so-called
“shell hook”. See the “Non-interactive use” vignette for more details.

## Windows how-to

Since Nixpkgs needs a UNIX environment, the Windows Subsystem for Linux
2 (WSL2) is required to build and run the nix shell under Windows. If
you are on a recent version of Windows 10 or 11, you can simply run this
as an administrator in the PowerShell.

``` ps
wsl --install
```

Further installation notes you can find at [this official MS
documentation](https://learn.microsoft.com/en-us/windows/wsl/install).

<<<<<<< HEAD
The only difference is that

``` sh
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
```

will be for single-user installations if you have `systemd` disabled
(default).

=======
>>>>>>> 8a34352 (revert addition to resolve conflict)
## Contributing

This package is developed using the `{fusen}` package. If you want to
contribute, please edit the `.Rmd` files found in the `dev/` folder.
Then, inflate the package using `fusen::inflate_all()`. If no errors are
found (warning and notes are ok), then commit and open a PR. To learn
how to use `{fusen}` (don’t worry, it’s super easy), refer to this
[vignette](https://thinkr-open.github.io/fusen/articles/How-to-use-fusen.html).
