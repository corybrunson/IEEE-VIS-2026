---
title: Balancing constriction and expansion for domain-specific grammars
author: Jason Cory Brunson
venue: IEEE VIS 2026
session: Grand Unified Grammar of Graphics
header-includes:
	\newcommand\Var{\operatorname{Var}}
	\newcommand\proj{\operatorname{proj}}
---

## Abstract

Graphical grammars distinguish from heuristic typologies in constituting closed formal systems whose product diversity arises from recombination rather than from _de novo_ redesign.
In practice, the scope of an implementation is constrained both by what options have been implemented for each component (for example, the polar coordinatization, the grouped count statistic, and the rectangle geometric element) and by what combinations are enabled (these three yielding a pie graphic).
In the interest of flexibility, implementations are generally permissive of syntactically valid combinations.
However, within some domains, universal or conditional rules may be in place to ensure that graphics faithfully or efficiently communicate important properties of the input data, such that grammatical implementations may compromise their integrity by permitting violations of these rules.
I will present geometric data analysis as a motivating case study for this situation.
Visualizations of point clouds, and especially the use of biplots, relies universally on a unitary aspect ratio and conditionally on data sphering for plot elements to approximate geometric relationships among data elements.
Rather than a limitation of graphical grammar, these should be viewed as opportunities to explore the _feasibility_ spaces of different graphical domains.
Indeed, the geometric constraints above enable the meaningful use of two families of statistical transformation---projections of constructions in higher dimensions and constructions in relation to referent points---that would otherwise produce uninterpretable graphics.
This leads me to argue for a change in language from Wilkinson (2005)'s assertion that, while a grammatical system can produce hideous graphics, it cannot produce meaningless ones.
I suggest that meaningfulness and meaninglessness are not mathematical properties secured by formal rules but semantic properties vested with cultural significance, and that graphical grammars must adapt to the culture of a domain in order to serve as trustworthy tools for communicating information within it.

\pagebreak

## Background

### Grammar of Graphics

Wilkinson (2005) emphasizes the value of closure in a system designed to ensure rigor and meaning in its outputs:

> The remarkable consequence of building a closed formal system is that, while it solves more complex applied problems, it can appear more adaptive to the user. Paradoxically, closed systems often behave more “openly” than open systems.

<!--
Implementations of graphical grammar systems are necessarily bounded in the plots they can produce, but these bounds may only become evident when systems prove unable to produce a prespecified desired graphic.
-->

theory
* 
* 

implementation
* 
* 

### Geometric Data Analysis

GDA is a diverse family of techniques for analyzing data represented as a point cloud---most commonly, a finite multisubset $X$ of $(\mathbb{R}^d, L^2)$---and for transforming ("embedding") other data types into point clouds prior to analysis.
While underlying variables may lie on incommensurate scales or even be of different types, the latent space $\mathbb{R}^d$ inherits no canonical coordinate basis from the data _specification_; instead, latent coordinates are derived from the data _values_.
Some techniques, broadly those called gradient analysis, use singular value decomposition to obtain an orthogonormal basis each vector $v_i$ of which maximizes $\Var(\proj_{v_i}(X_{i-1}))$, where $X_{i-1}$ is the projection onto the previous $v_{i-1}$ (starting with $X_0 = X$).
The best known of these are probably principal components analysis, which obtains $X$ by centering and scaling a numeric case--variable data, and correspondence analysis, which obtains a matrix of standardized residuals from bivariate count data.
Other techniques, most notably factor analysis, fit latent factor models to data and use these latent factors to coordinatize the latent space.
These latent factors are often invested with interpretation and may be predicted for new data; in contrast, the coordinate bases obtained from gradient analysis may be called "scaffolding" to emphasize their lack of intrinsic meaning.

This paper focuses primarily on SVD-based techniques.


While several were developed independently, they have in common their dual-purpose scaffolding coordinates
Greenacre () emphasizes this unity as the 
