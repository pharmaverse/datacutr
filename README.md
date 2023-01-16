# datacutr <img src="man/figures/logo.png" align="right" width="200" style="margin-left:50px;"/>

SDTM Datacut in R

<!-- badges: start -->

<!-- note: insert datacutr shield here when ready -->

[<img src="http://pharmaverse.org/shields/datacutr.svg">](https://pharmaverse.org)

<!-- note: insert CRAN Status here when ready -->

<!-- note: insert Test status here when ready -->

[![Test Coverage](https://raw.githubusercontent.com/pharmaverse/datacutr/badges/devel/test-coverage.svg)](https://github.com/pharmaverse/datacutr/actions/workflows/code-coverage.yml)

<!-- badges: end -->

## Purpose

To provide an open source tool that enables the pharmaceutical programming community
to apply a data cut to SDTM data in R.

## Installation

The package is not currently available on CRAN, but the latest development version can be installed directly from GitHub using the following code:

```r
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

remotes::install_github("pharmaverse/datacutr", ref = "devel")
```

## Scope

This package works with tabulation data following an SDTM standard. For ease of processing, the assumption is that supplemental qualifiers have been combined with their parent domain prior to the application of the cut process (sometimes labeled as SDTMv). The user has the flexibility to select the type of cut applied to each SDTM domain (either no cut, patient cut, date cut, or a special DM cut).

## References and Documentation

* Please go to [Get Started](https://pharmaverse.github.io/datacutr/articles/datacutr.html) section to start using `{datacutr}`
* Please go to [Function Reference](https://pharmaverse.github.io/datacutr/reference/index.html) section for a break down of all functions created by `{datacutr}`
* Please see the [Contribution Model](https://pharmaverse.github.io/datacutr/articles/contribution_model.html) for how to get involved with making contributions

## Contact

Whilst the package is under development please feel free to reach out to one of the core developers:

* Tim Barnett (Maintainer) - [timothy.barnett@roche.com](timothy.barnett@roche.com)
* Nathan Rees - [nathan.rees@roche.com](nathan.rees@roche.com)
* Alana Harris - [alana.harris@roche.com](alana.harris@roche.com)

Once the package is finalized we will use the following for support and communications between user and developer community:

* [Slack](https://app.slack.com/client/T028PB489D3/C02M8KN8269) - for informal discussions, Q\&A and building our user community. If you don't have access, use this [link](https://join.slack.com/t/pharmaverse/shared_invite/zt-yv5atkr4-Np2ytJ6W_QKz_4Olo7Jo9A) to join the pharmaverse Slack workspace
* [GitHub Issues](https://github.com/pharmaverse/datacutr/issues) - for direct feedback, enhancement requests or raising bugs
