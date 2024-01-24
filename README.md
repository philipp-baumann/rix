
-   [Reproducible Environments with
    Nix](#reproducible-environments-with-nix)
    -   [Introduction](#introduction)
    -   [Quick start for returning
        users](#quick-start-for-returning-users)
    -   [Getting started for new users](#getting-started-for-new-users)
        -   [Docker](#docker)
    -   [Contributing](#contributing)
    -   [Thanks](#thanks)
    -   [Recommended reading](#recommended-reading)

<!-- badges: start -->

[![R-CMD-check](https://github.com/b-rodrigues/rix/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/b-rodrigues/rix/actions/workflows/R-CMD-check.yaml)
[![runiverse-package
rix](https://b-rodrigues.r-universe.dev/badges/rix?scale=1&color=pink&style=round)](https://b-rodrigues.r-universe.dev/rix)
[![Docs](https://img.shields.io/badge/docs-release-blue.svg)](https://b-rodrigues.github.io/rix)
<!-- badges: end -->

<!-- README.md is generated from README.Rmd. Please edit that file -->

<img src="man/figures/logo.png" align="right" style="width: 25%;"/>

# Reproducible Environments with Nix

## Introduction

`{rix}` is an R package that leverages Nix, a powerful package manager
focusing on reproducible builds. With Nix, it is possible to create
project-specific environments that contain a project-specific version of
R and R packages (as well as other tools or languages, if needed). You
can use `{rix}` and Nix to replace `{renv}` and Docker with one single
tool. Nix is an incredibly useful piece of software for ensuring
reproducibility of projects, in research or otherwise, or for running
web applications like Shiny apps or `{plumber}` APIs in a controlled
environment.

Nix has quite a high entry cost though, because Nix is a complex piece
of software that comes with its own programming language (also called
Nix) whose purpose is to solve a complex problem: installing software in
a reproducible manner, on any operating system or hardware.

`{rix}` provides functions to help you write Nix expressions (written in
the Nix language): these expressions can then be used by the Nix package
manager to build completely reproducible development environments. These
environments can be used for interactive data analysis or running
pipelines in a CI/CD environment. Environments built with Nix contain R
and all the required packages that you need for your project: there are
currently more than 80.000 pieces of software available through the Nix
package manager, including the entirety of CRAN and Bioconductor
packages. It is also possible to install older releases of packages, or
install packages from GitHub.

The Nix package manager is extremely powerful: not only it handles all
the dependencies of any package extremely well, it is also possible with
it to reproduce environments containing old releases of software. It is
thus possible to build environments that contain R version 4.0.0 (for
example) to run an old project originally developed on that version of
R.

As stated above, with Nix, it is essentially possible to replace
`{renv}` and Docker combined. If you need other tools or languages like
Python or Julia, this can also be done easily. Nix is available for
Linux, macOS and Windows (via WSL2) and `{rix}` comes with the following
features:

-   install any version of R and R packages for specific projects;
-   have several versions of R and R packages installed at the same time
    on the same system;
-   define complete development environments as code and use them
    anywhere;
-   run single function in a different environment (potentially with a
    different R version and R packages) for an interactive R session and
    get back the output of that function using `with_nix()`;

`{rix}` does not require Nix to be installed on your system to generate
expressions. This means that you can generate expressions on a system on
which you cannot easily install software, and then use these expressions
on the cloud or on a CI/CD environment to build the project there.

## Quick start for returning users

*If you are not familiar with Nix or `{rix}` skip to the next section.*

If you are already familiar with Nix and R, and simply want to get
started as quickly as possible, you can start by installing Nix using
the installer from [Determinate
Systems](https://determinate.systems/posts/determinate-nix-installer) a
company that provides services and tools built on Nix:

``` sh
curl --proto '=https' --tlsv1.2 -sSf \
    -L https://install.determinate.systems/nix | \
     sh -s -- install
```

If you have R installed, you can start straight away from your R session
by first installing `{rix}`:

``` r
install.packages("rix", repos = c("https://b-rodrigues.r-universe.dev",
  "https://cloud.r-project.org"))

library("rix")
```

You can check that everything works well by trying to build the Nix
expression that ships with `{rix}`. Nix expressions are typically saved
into files with the name `default.nix` or `shell.nix`. This expression
installs the latest version of R and `{rix}` in a separate, reproducible
environment:

``` r
file.copy(
  # default.nix is the file containing the Nix expression
  from = system.file("extdata", "default.nix", package = "rix"),
  to = ".", overwrite = TRUE
)

# nix_build() is a wrapper around the command line tool `nix-build`
nix_build(project_path = ".")
```

If everything worked well, you should see a file called `result` next to
`default.nix`. You can now enter this newly built development
environment by opening a terminal in that folder and typing `nix-shell`.
You should be immediately dropped into an interactive R session.

If you don’t have R installed, but have the Nix package manager
installed, you can run a temporary R session with R using this command
(it will build the same environment as the one above):

    nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/b-rodrigues/rix/master/inst/extdata/default.nix)"

You can then create new development environment definitions, build them,
and start using them.

## Getting started for new users

To get started with `{rix}` and Nix, you should read the following
vignette `vignette("1-getting_started")`. The vignettes are numbered to
get you to learn how to use `{rix}` and Nix smoothly. There’s a lot of
info, so take your time reading the vignettes. Don’t hesitate to open an
issue if something is not clear.

### Docker

You can also try out Nix inside Docker. To do so, you can start your
image from the [NixOS Docker
image](https://hub.docker.com/r/nixos/nix/). NixOS is a full GNU/Linux
distribution that uses Nix as its system package manager.

## Contributing

This package is developed using the `{fusen}` package. If you want to
contribute, please edit the `.Rmd` files found in the `dev/` folder.
Then, inflate the package using `fusen::inflate_all()`. If no errors are
found (warning and notes are OK), then commit and open a PR. To learn
how to use `{fusen}` (don’t worry, it’s super easy), refer to this
[vignette](https://thinkr-open.github.io/fusen/articles/How-to-use-fusen.html).
In our development workflow, we use [semantic
versioning](https://semver.org) via
[{fledge}](https://fledge.cynkra.com).

## Thanks

Thanks to the [Nix community](https://nixos.org/community/) for making
Nix possible, and thanks to the community of R users on Nix for their
work packaging R and CRAN/Bioconductor packages for Nix (in particular
[Justin Bedő](https://github.com/jbedo), [Rémi
Nicole](https://github.com/minijackson),
[nviets](https://github.com/nviets), [Chris
Hammill](https://github.com/cfhammill), [László
Kupcsik](https://github.com/Kupac), [Simon
Lackerbauer](https://github.com/ciil),
[MrTarantoga](https://github.com/MrTarantoga) and every other person
from the [Matrix Nixpkgs R channel](https://matrix.to/#/#r:nixos.org)).

## Recommended reading

-   [NixOS’s website](https://nixos.org/)
-   [Nixpkgs’s GitHub repository](https://github.com/NixOS/nixpkgs)
-   [Nix for R series from Bruno’s
    blog](https://www.brodrigues.co/tags/nix/). Or, in case you like
    video tutorials, watch [this one on Reproducible R development
    environments with Nix](https://www.youtube.com/watch?v=c1LhgeTTxaI)
-   [nix.dev
    tutorials](https://nix.dev/tutorials/first-steps/towards-reproducibility-pinning-nixpkgs#pinning-nixpkgs)
-   [INRIA’s Nix
    tutorial](https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/installation.html)
-   [Nix pills](https://nixos.org/guides/nix-pills/)
-   [Nix for Data
    Science](https://github.com/nix-community/nix-data-science)
-   [NixOS explained](https://christitus.com/nixos-explained/): NixOS is
    an entire Linux distribution that uses Nix as its package manager.
-   [Blog post: Nix with R and
    devtools](https://rgoswami.me/posts/nix-r-devtools/)
-   [Blog post: Statistical Rethinking and
    Nix](https://rgoswami.me/posts/rethinking-r-nix/)
-   [Blog post: Searching and installing old versions of Nix
    packages](https://lazamar.github.io/download-specific-package-version-with-nix/)
