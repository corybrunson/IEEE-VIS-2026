---
title: Balancing constriction and expansion for domain-specific grammars
author: Jason Cory Brunson
venue: IEEE VIS 2026
session: Grand Unified Grammar of Graphics
abstract: |
  Graphical grammars distinguish from heuristic typologies in constituting closed formal systems whose product diversity arises from recombination rather than from _de novo_ redesign.
  In practice, the scope of an implementation is constrained both by what options have been implemented for each component (for example, the polar coordinatization, the grouped count statistic, and the rectangle geometric element) and by what combinations are enabled (these three yielding a pie graphic).
  In the interest of flexibility, implementations are generally permissive of syntactically valid combinations.
  However, within some domains, universal or conditional rules may be in place to ensure that graphics faithfully or efficiently communicate important properties of the input data, such that grammatical implementations may compromise their integrity by permitting violations of these rules.
  I will present geometric data analysis as a motivating case study for this situation.
  Visualizations of point clouds, and especially the use of biplots, relies universally on a unitary aspect ratio and conditionally on data sphering for plot elements to approximate geometric relationships among data elements.
  Rather than a limitation of graphical grammar, these should be viewed as opportunities to explore the feasibility spaces of different graphical domains.
  Indeed, the geometric constraints above enable the meaningful use of two families of statistical transformation---projections of constructions in higher dimensions and constructions in relation to referent points---that would otherwise produce uninterpretable graphics.
  This leads me to argue for a change in language from Wilkinson's assertion that, while a grammatical system can produce hideous graphics, it cannot produce meaningless ones.
  I suggest that meaningfulness and meaninglessness are not mathematical properties secured by formal rules but semantic properties vested with cultural significance, and that graphical grammars must adapt to the culture of a domain in order to serve as trustworthy tools for communicating information within it.
header-includes:
  \newcommand\R{\mathbb{R}}
  \newcommand\diag{\operatorname{diag}}
  \newcommand\Var{\operatorname{Var}}
  \newcommand\proj{\operatorname{proj}}
---

<!--
Pandoc via TeX to PDF:
pandoc Brunson-GDA-GoG.md -o Brunson-GDA-GoG.pdf
-->

\pagebreak

## Grammar of Graphics

Wilkinson (2005) emphasizes the value not only to the rigor but also to the extensibility of taking a grammatical, in opposition to a typological, approach to statistical graphics:

> The remarkable consequence of building a closed formal system is that, while it solves more complex applied problems, it can appear more adaptive to the user. Paradoxically, closed systems often behave more “openly” than open systems.

This flexibility assumes and relies on a permissiveness toward the graphics that may be realized through syntactically valid phrases. Indeed, [hideous; meaningful]. On my reading, the primary focus, in the interest of meaningfulness, is on the mathematical determinism connecting the data to the geometric elements that constitute a graphic---which Wilkinson ultimately defines as a visual representation of the abstract _graph_ of a mathematical function.

It would be wrong to caricature this point with a graphical analog to Chomsky's "colorless green ideas sleep furiously": Wilkinson details elsewhere how meaningful graphics must also account for human perceptual tendencies (e.g. avoid deviations from realistic patterns in graphics meant to activate everyday perceptual strengths) and for cultural norms. Popular implementations reflect this: While some rules are imposed, e.g. by limiting the channels of communication between objects during plot assembly, most directives in the interest of good practice take the form of defaults (e.g. different color palettes for categorical, ordinal, and numerical variables) and warnings (e.g. that opacity should not be used to encode a discrete variable). Moreover, Wilkinson posits certain nearly-universal constraints, for example that the plotting window should be sized to fit the input data, even if only summary statistics are visualized (p. 219).
<!--
Implementations of graphical grammar systems are necessarily bounded in the plots they can produce, but these bounds may only become evident when systems prove unable to produce a prespecified desired graphic.
-->

What is missing in this account, i will argue, is a reckoning with dialect: Certain disciplines use/produce specialized graphics whose uniquely structured content imposes specialized sets of rules, so that extending the grammatical approach to produce them requires constraining the combinatorial freedom it makes possible. Rather than choosing between a [freespirited] extension that encourages misleading graphics and a largely duplicative re-implementation for each such domain, we should design and adopt formal principles to link essential data properties to graphical design patterns that must be sensitive to them.
<!--
in implementation: similar to registration as in {ggraph}?
-->

## Geometric Data Analysis

GDA is a diverse family of techniques for analyzing data represented as a _point cloud_---most commonly, a finite multisubset $X \subset (\R^d, L^2)$---and for transforming (_embedding_) other data types into point clouds prior to analysis.
The points $x_i \in X$ may be attributed _masses_ $m_i$ according to empirical measurements, or masses may be induced by the transformation.
Most commonly, the centroid of $X$ is taken as the origin in a recoordinatization of $\R^d$, so that the point _inertias_ $m_i \lVert \vec{x} \rVert \vec{x}_i$ sum to zero.
A foundational step in GDA, somewhat analogous to ANOVA in the analysis of factorial data, is the decomposition of inertia by way of singular value decomposition (SVD):
Taking $X_{n \times m}$ to be centered and $r \leq min(n,m)$, we obtain $$ X = U_{n \times r} \Sigma_{r \times r} {V_{m \times r}}^\top $$ with coordinatewise inertias $\diag(\Sigma) = (\sigma_1,\ldots,\sigma_r)$ along the diagonal matrix.
In general, the point cloud $F = U\Sigma$ is a rotation of $X$ when $r = \min(n,m)$ and of a sum squared error--optimal approximation to $X$ otherwise; the column vectors $\vec{v}_1,\ldots,\vec{v}_r$ of $V$ each maximize $\Var(\proj_{v_i}F_{i-1})$, where $F_{i-1}$ is the projection onto the previous $v_{i-1}$ (starting with $F_0 = F$); and each $\Var(\proj_{v_i}F_{i-1}) = {\sigma_i}^2$.
SVD thus obtains a set of _artificial coordinates_ for the proxy point cloud $F$.

Two of the most widely used are principal components analysis (PCA), which obtains $X$ by centering and scaling a numeric case--variable data, and correspondence analysis (CA), which obtains a matrix of standardized residuals from bivariate count data.
These techniques are called _ordination_ or _gradient analysis_ methods, by comparison to _regression_ (which is supervised, whereas ordination is usually unsupervised) and to _cluster analysis_ (which obtains artificial variables that are discrete rather than continuous).
Readers familiar with either technique will recall that their artificial coordinates (called principal axes or coordinates) are not specified from a model but derived from the measured values in the data; they carry no intrinsic meaning and for this reason are sometimes called _scaffolding_.
(This also contrasts, for example, with factor analysis, which fits latent factor models to data and invests these latent factors with interpretations based on how the observed cases fall along them.)

The SVD underprops a unique statistical graphic, the _biplot_, introduced by Gabriel ().
Because the matrices $U$ and $V$ share their $r$ artificial column variables, row markers for both (ultimately row and column markers, respectively, for $X$) can be overlaid on the artificial coordinate space.
When done properly, this is not a gimmick:
When $F$ and $V$ are overlaid, the scalar product of the $i^\text{th}$ row marker and the $j^\text{th}$ column marker approximates $x_{ij}$; this is also true for $U$ and $G = VD$.
In general, a biplot overlay of $UD^a$ and $VD^b$, with $0 \leq a,b \leq 1$, is called _balanced_ when $a + b = 1$, so that row--column inner products approximate measurements.
The inertia-laden matrices $F$ and $G$ are said to contain _principal coordinates_ for the rows and columns of $X$, while $U$ and $V$ contain _standard coordinates_ of unit magnitude.
When a matrix factor is represented in principal coordinates, the graphic approximates its geometry in the standard coordinate space of the other factor:
In PCA, distances between the markers of $F$ approximate those between the rows of $X$ in the space of measured variables, while inner products and cosines between the markers of $G$ approximate covariances and correlations between the columns of $X$ across the case measurements.
In CA, distances between markers of $F$ and of $G$ approximate $\chi^2$ distances between row and column profiles in the original count table.

Greenacre (2010) uses biplots to surface the theoretical unity of these techniques.
However, their shared mathematical underpinnings are well-documented but rarely reflected in software packages, at least in R.
Implementations of PCA, CA, multiple correspondence analysis, canonical correlation analysis, and linear discriminant analysis (equivalently, canonical variates analyssi) in {stats} and {MASS}, for example, share no source code beyond `base::svd()` (if that), accept dissimilar arguments even for shared parameters (e.g. the rank $r$), and produce output of classes with few shared methods.
The {ordr} package, my attempt to harmonize these tools through a tidyverse-inspired API that foregrounds this common theory, is the source for the tensions and synergies i describe in the next sections.

## Tensions between GDA and GoG

Variables in GDA 

## 


