# WARNING - Generated by {fusen} from dev/flat_nix_build.Rmd: do not edit by hand

#' Invoke shell command `nix-build` from an R session
#' @param project_path Path to the folder where the `default.nix` file resides. 
#' The default is `"."`, which is the working directory in the current R
#' session.
#' @param exec_mode Either `"blocking"` (default) or `"non-blocking`. This
#' will either block the R session while the `nix-build` shell command is
#' executed, or run `nix-build` in the background ("non-blocking").
#' @return integer of the process ID (PID) of `nix-build` shell command
#' launched, if `nix_build()` call is assigned to an R object. Otherwise, it 
#' will be returned invisibly.
#' @details The `nix-build` command line interface has more arguments. We will
#' probably not support all of them in this R wrapper, but currently we have
#' support for the following `nix-build` flags:
#' - `--max-jobs`: Maximum number of build jobs done in parallel by Nix.
#'   According to the official docs of Nix, it defaults to `1`, which is one
#'   core. This option can be useful for shared memory multiprocessing or
#'   systems with high I/O latency. To set `--max-jobs` used, you can declare
#'   with `options(rix.nix_build_max_jobs = <integer>)`. Once you call
#'   `nix_build()` the flag will be propagated to the call of `nix-build`.
#' @export
#' @examples
#' \dontrun{
#'   nix_build()
#' }
nix_build <- function(project_path = ".",
                      exec_mode = c("blocking", "non-blocking")) {
  # if nix store is not PATH variable; e.g. on macOS (system's) RStudio
  PATH <- set_nix_path()
  has_nix_build <- nix_build_installed() # TRUE if yes, FALSE if no
  nix_file <- file.path(project_path, "default.nix")

  stopifnot(
    "`project_path` must be character of length 1." =
      is.character(project_path) && length(project_path) == 1L,
    "`project_path` has no `default.nix` file. Use one that contains `default.nix`" =
      file.exists(nix_file),
    "`nix-build` not available. To install, we suggest you follow https://zero-to-nix.com/start/install ." =
      isTRUE(has_nix_build)
  )
  exec_mode <- match.arg(exec_mode)
 
  max_jobs <- getOption("rix.nix_build_max_jobs", default = 1L)
  stopifnot("option `rix.nix_build_max_jobs` is not integerish" =
    is_integerish(max_jobs))
  max_jobs <- as.integer(max_jobs)

  if (max_jobs == 1L) {
    cmd <- c("nix-build", nix_file)
  } else {
    cmd <- c("nix-build", "--max-jobs", as.character(max_jobs), nix_file)
  }

  cat(paste0("Launching `", paste0(cmd, collapse = " "), "`", " in ",
    exec_mode, " mode\n"))

  proc <- switch(exec_mode,
    "blocking" = sys::exec_internal(cmd = cmd),
    "non-blocking" = sys::exec_background(cmd = cmd),
    stop('invalid `exec_mode`. Either use "blocking" or "non-blocking"')
  )

  if (exec_mode == "non-blocking") {
    poll_sys_proc_nonblocking(cmd, proc, what = "nix-build")
  } else if (exec_mode == "blocking") {
    poll_sys_proc_blocking(cmd, proc, what = "nix-build")
  }

  # todo (?): clean zombies for background/non-blocking mode

  return(invisible(proc))
}

#' @noRd
poll_sys_proc_blocking <- function(cmd, proc,
                                   what = c("nix-build", "expr")) {
  what <- match.arg(what)
  status <- proc$status
  if (status == 0L) {
    cat(paste0("\n==> ", sys::as_text(proc$stdout)))
    cat(paste0("\n==> `", what, "` succeeded!", "\n"))
  } else {
    msg <- nix_build_exit_msg()
    cat(paste0("`", cmd, "`", " failed with ", msg))
  }
  return(invisible(status))
}

#' @noRd
poll_sys_proc_nonblocking <- function(cmd, proc, 
                                      what = c("nix-build", "expr")) {
  what <- match.arg(what)
  cat(paste0("\n==> Process ID (PID) is ", proc, "."))
  cat("\n==> Receiving stdout and stderr streams...\n")
  status <- sys::exec_status(proc, wait = TRUE)
  if (status == 0L) {
    cat(paste0("\n==> `", what, "` succeeded!"))
  }
  return(invisible(status))
}

#' @noRd
is_integerish <- function(x, tol = .Machine$double.eps^0.5) {
  return(abs(x - round(x)) < tol)
}

#' @noRd
nix_build_installed <- function() {
  exit_code <- system2("command", "-v", "nix-build")
  if (exit_code == 0L) {
    return(invisible(TRUE))
  } else {
    return(invisible(FALSE))
  }
}

#' @noRd
nix_build_exit_msg <- function(x) {
  x_char <- as.character(x)
  
  err_msg <- switch(
    x_char,
    "100" = "generic build failure (100).",
    "101" = "build timeout (101).",
    "102" = "hash mismatch (102).",
    "104" = "not deterministic (104).",
    stop(paste0("general exit code ", x_char, "."))
  )
  
  return(err_msg)
}