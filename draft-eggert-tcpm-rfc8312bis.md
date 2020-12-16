---

title: CUBIC for Fast Long-Distance Networks
abbrev: CUBIC
docname: draft-eggert-tcpm-rfc8312bis-latest
date: {DATE}
category: std
ipr: trust200902
area: Transport
workgroup: TCPM
obsoletes: 8312

stand_alone: yes
pi: [toc, sortrefs, symrefs, docmapping]

author:

-
  name: Lisong Xu
  org: University of Nebraska-Lincoln
  abbrev: UNL
  street: Department of Computer Science and Engineering
  city: Lincoln
  region: NE
  code: 68588-0115
  country: USA
  email: xu@unl.edu
  uri: "https://cse.unl.edu/~xu/"
-
  name: Sangtae Ha
  org: University of Colorado at Boulder
  abbrev: Colorado
  street: Department of Computer Science
  city: Boulder
  region: CO
  code: 80309-0430
  country: USA
  email: sangtae.ha@colorado.edu
  uri: "https://netstech.org/sangtaeha/"
-
  name: Vidhi Goel
  org: Apple Inc.
  street: One Apple Park Way
  city: Cupertino
  region: California
  code: 95014
  country: USA
  email: vidhi_goel@apple.com
-
  name: Lars Eggert
  org: NetApp
  street: Stenbergintie 12 B
  city: Kauniainen
  code: "02700"
  country: FI
  email: lars@eggert.org
  uri: "https://eggert.org/"
  role: editor

informative:
  FHP00:
    title: A Comparison of Equation-Based and AIMD Congestion Control
    date: 2000-5
    author:
    - ins: S. Floyd
    - ins: M. Handley
    - ins: J. Padhye
    target: "https://www.icir.org/tfrc/aimd.pdf"

  GV02:
    title: Extended Analysis of Binary Adjustment Algorithms
    date: 2002-8-11
    seriesinfo:
      Technical Report: TR2002-29
      Department of: Computer Sciences
      The University of Texas: at Austin
    author:
    - ins: S. Gorinsky
    - ins: H. Vin
    target: "http://www.cs.utexas.edu/ftp/techreports/tr02-39.ps.gz"

  HKLRX06:
    title:
      A Step toward Realistic Performance Evaluation of High-Speed TCP Variants
    date: 2006-2
    seriesinfo:
      International Workshop on: Protocols for Fast Long-Distance Networks
    author:
    - ins: S. Ha
    - ins: Y. Kim
    - ins: L. Le
    - ins: I. Rhee
    - ins: L. Xu
    target: "https://pfld.net/2006/paper/s2_03.pdf"

  HR08:
    title: Hybrid Slow Start for High-Bandwidth and Long-Distance Networks
    date: 2008
    seriesinfo:
      International Workshop on: Protocols for Fast Long-Distance Networks
    author:
    - ins: S. Ha
    - ins: I. Rhee
    target: "https://pdfs.semanticscholar.org/25e9/ef3f03315782c7f1cbcd31b587857adae7d1.pdf"

  XHR04:
    title: Binary Increase Congestion Control (BIC) for Fast Long-Distance Networks
    date: 2004-3
    seriesinfo:
      IEEE INFOCOM: 2004
      DOI: 10.1109/infcom.2004.1354672
    author:
    - name: Lisong Xu
    - name: Khaled Harfoush
    - name: Injong Rhee

  CEHRX07:  DOI.10.1109/INFCOM.2007.111
  HRX08:    DOI.10.1145/1400097.1400105
  K03:      DOI.10.1145/956981.956989

--- abstract

CUBIC is an extension to the current TCP standards. It differs from
the current TCP standards only in the congestion control algorithm on
the sender side. In particular, it uses a cubic function instead of
a linear window increase function of the current TCP standards to
improve scalability and stability under fast and long-distance
networks. CUBIC and its predecessor algorithm have been adopted as
defaults by Linux and have been used for many years. This document
provides a specification of CUBIC to enable third-party
implementations and to solicit community feedback through
experimentation on the performance of CUBIC.

This documents obsoletes {{?RFC8312}}, updating the specification of
CUBIC to conform to the current Linux version.

--- note_Note_to_Readers

Discussion of this draft takes place on the [TCPM working group mailing
list](mailto:tcpm@ietf.org), which is archived at
[](https://mailarchive.ietf.org/arch/browse/tcpm/).

Working Group information can be found at
[](https://datatracker.ietf.org/wg/tcpm/); source code and issues list for this
draft can be found at [](https://github.com/NTAP/rfc8312bis).

--- middle

# Introduction

The low utilization problem of TCP in fast long-distance networks is
well documented in {{?K03}} and {{?RFC3649}}. This problem arises from a
slow increase of the congestion window following a congestion event
in a network with a large bandwidth-delay product (BDP). {{HKLRX06}}
indicates that this problem is frequently observed even in the range
of congestion window sizes over several hundreds of packets. This
problem is equally applicable to all Reno-style TCP standards and
their variants, including TCP-Reno {{!RFC5681}}, TCP-NewReno
{{!RFC6582}}{{!RFC6675}}, SCTP {{?RFC4960}}, and TFRC {{!RFC5348}}, which
use the same linear increase function for window growth, which we refer to
collectively as "Standard TCP" below.

CUBIC, originally proposed in {{?HRX08}}, is a modification to the
congestion control algorithm of Standard TCP to remedy this problem.
This document describes the most recent specification of CUBIC.
Specifically, CUBIC uses a cubic function instead of a linear window
increase function of Standard TCP to improve scalability and
stability under fast and long-distance networks.

Binary Increase Congestion Control (BIC-TCP) {{XHR04}}, a predecessor
of CUBIC, was selected as the default TCP congestion control
algorithm by Linux in the year 2005 and has been used for several
years by the Internet community at large. CUBIC uses a similar
window increase function as BIC-TCP and is designed to be less
aggressive and fairer to Standard TCP in bandwidth usage than BIC-TCP
while maintaining the strengths of BIC-TCP such as stability, window
scalability, and RTT fairness. CUBIC has already replaced BIC-TCP as
the default TCP congestion control algorithm in Linux and has been
deployed globally by Linux. Through extensive testing in various
Internet scenarios, we believe that CUBIC is safe for testing and
deployment in the global Internet.

In the following sections, we first briefly explain the design
principles of CUBIC, then provide the exact specification of CUBIC,
and finally discuss the safety features of CUBIC following the
guidelines specified in {{!RFC5033}}.

# Conventions

{::boilerplate bcp14}

# Design Principles of CUBIC

CUBIC is designed according to the following design principles:

Principle 1:
: For better network utilization and stability, CUBIC
uses both the concave and convex profiles of a cubic function to
increase the congestion window size, instead of using just a
convex function.

Principle 2:
: To be TCP-friendly, CUBIC is designed to behave like
Standard TCP in networks with short RTTs and small bandwidth where
Standard TCP performs well.

Principle 3:
: For RTT-fairness, CUBIC is designed to achieve linear
bandwidth sharing among flows with different RTTs.

Principle 4:
: CUBIC appropriately sets its multiplicative window
decrease factor in order to balance between the scalability and
convergence speed.

Principle 1: For better network utilization and stability, CUBIC
{{?HRX08}} uses a cubic window increase function in terms of the elapsed
time from the last congestion event. While most alternative
congestion control algorithms to Standard TCP increase the congestion
window using convex functions, CUBIC uses both the concave and convex
profiles of a cubic function for window growth. After a window
reduction in response to a congestion event is detected by duplicate
ACKs or Explicit Congestion Notification-Echo (ECN-Echo) ACKs
{{!RFC3168}}, CUBIC registers the congestion window size where it got
the congestion event as *W<sub>max</sub>* and performs a multiplicative decrease
of congestion window. After it enters into congestion avoidance, it
starts to increase the congestion window using the concave profile of
the cubic function. The cubic function is set to have its plateau at
*W<sub>max</sub>* so that the concave window increase continues until the window
size becomes *W<sub>max</sub>*. After that, the cubic function turns into a
convex profile and the convex window increase begins. This style of
window adjustment (concave and then convex) improves the algorithm
stability while maintaining high network utilization {{?CEHRX07}}. This
is because the window size remains almost constant, forming a plateau
around *W<sub>max</sub>* where network utilization is deemed highest. Under
steady state, most window size samples of CUBIC are close to *W<sub>max</sub>*,
thus promoting high network utilization and stability. Note that
those congestion control algorithms using only convex functions to
increase the congestion window size have the maximum increments
around *W<sub>max</sub>*, and thus introduce a large number of packet bursts
around the saturation point of the network, likely causing frequent
global loss synchronizations.

Principle 2: CUBIC promotes per-flow fairness to Standard TCP. Note
that Standard TCP performs well under short RTT and small bandwidth
(or small BDP) networks. There is only a scalability problem in
networks with long RTTs and large bandwidth (or large BDP). An
alternative congestion control algorithm to Standard TCP designed to
be friendly to Standard TCP on a per-flow basis must operate to
increase its congestion window less aggressively in small BDP
networks than in large BDP networks. The aggressiveness of CUBIC
mainly depends on the maximum window size before a window reduction,
which is smaller in small BDP networks than in large BDP networks.
Thus, CUBIC increases its congestion window less aggressively in
small BDP networks than in large BDP networks. Furthermore, in cases
when the cubic function of CUBIC increases its congestion window less
aggressively than Standard TCP, CUBIC simply follows the window size
of Standard TCP to ensure that CUBIC achieves at least the same
throughput as Standard TCP in small BDP networks. We call this
region where CUBIC behaves like Standard TCP, the "TCP-friendly
region".

Principle 3: Two CUBIC flows with different RTTs have their
throughput ratio linearly proportional to the inverse of their RTT
ratio, where the throughput of a flow is approximately the size of
its congestion window divided by its RTT. Specifically, CUBIC
maintains a window increase rate independent of RTTs outside of the
TCP-friendly region, and thus flows with different RTTs have similar
congestion window sizes under steady state when they operate outside
the TCP-friendly region. This notion of a linear throughput ratio is
similar to that of Standard TCP under high statistical multiplexing
environments where packet losses are independent of individual flow
rates. However, under low statistical multiplexing environments, the
throughput ratio of Standard TCP flows with different RTTs is
quadratically proportional to the inverse of their RTT ratio {{XHR04}}.
CUBIC always ensures the linear throughput ratio independent of the
levels of statistical multiplexing. This is an improvement over
Standard TCP. While there is no consensus on particular throughput
ratios of different RTT flows, we believe that under wired Internet,
use of a linear throughput ratio seems more reasonable than equal
throughputs (i.e., the same throughput for flows with different RTTs)
or a higher-order throughput ratio (e.g., a quadratical throughput
ratio of Standard TCP under low statistical multiplexing
environments).

Principle 4: To balance between the scalability and convergence
speed, CUBIC sets the multiplicative window decrease factor to 0.7
while Standard TCP uses 0.5. While this improves the scalability of
CUBIC, a side effect of this decision is slower convergence,
especially under low statistical multiplexing environments. This
design choice is following the observation that the author of
HighSpeed TCP (HSTCP) {{?RFC3649}} has made along with other researchers
(e.g., {{GV02}}): the current Internet becomes more asynchronous with
less frequent loss synchronizations with high statistical
multiplexing. Under this environment, even strict Multiplicative-Increase
Multiplicative-Decrease (MIMD) can converge. CUBIC flows
with the same RTT always converge to the same throughput independent
of statistical multiplexing, thus achieving intra-algorithm fairness.
We also find that under the environments with sufficient statistical
multiplexing, the convergence speed of CUBIC flows is reasonable.

# CUBIC Congestion Control

In this section, we discuss how the congestion window is updated
during the different stages of the CUBIC congestion controller.

## Definitions

The unit of all window sizes in this document is segments of the
maximum segment size (MSS), and the unit of all times is seconds.

### Constants of interest

*{{{β}{}}}<sub>cubic</sub>*:
CUBIC multiplication decrease factor as described in {{mult-dec}}

*C*:
constant that determines the aggressiveness of CUBIC in competing
with other congestion control algorithms in high BDP networks. Please see
{{discussion}} for more explanation on how it is set. The unit for
*C* is

~~~ math
\frac{segment}{second^3}
~~~
{: artwork-align="center" }

### Variables of interest

Variables required to implement CUBIC are described in this section.

RTT:
Smoothed round-trip time in seconds calculated as described in {{!RFC6298}}

*cwnd*:
Current congestion window in segments

*ssthresh*:
Current slow start threshold in segments

*W<sub>max</sub>*:
Size of *cwnd* in segments just before *cwnd* is reduced in the
last congestion event

*K*:
The time period in seconds it takes to increase the current congestion
window size to *W<sub>max</sub>*

*current_time*:
Current time of the system in seconds

*epoch_start*:
The time in seconds at which the current congestion avoidance stage starts

W<sub>cubic</sub>(t):
Target value of the congestion window in segments at time t in seconds
based on the cubic increase function as described in {{win-inc}}

*target*:
Target value of congestion window in segments after the next RTT,
that is, W<sub>cubic</sub>(t + RTT) as described in {{win-inc}}

*W<sub>est</sub>*:
An estimate for the congestion window in segments in the TCP-friendly
region, that is, an estimate for the congestion window using the AIMD
approach similar to TCP-NewReno congestion controller

## Window Increase Function {#win-inc}

CUBIC maintains the acknowledgment (ACK) clocking of Standard TCP by
increasing the congestion window only at the reception of an ACK. It
does not make any change to the fast recovery and retransmit of TCP,
such as TCP-NewReno {{!RFC6582}}{{!RFC6675}}. During congestion avoidance
after a congestion event where a packet loss is detected by duplicate
ACKs or a network congestion is detected by ACKs with ECN-Echo flags
{{!RFC3168}}, CUBIC changes the window increase function of Standard
TCP.

CUBIC uses the following window increase function:

~~~ math
\mathrm{W_{cubic}}(t) = C * (t - K)^3 + W_{max}
~~~
{: #eq1 artwork-align="center" }

where t is the elapsed time in seconds from the beginning of the
current congestion avoidance stage, that is,

~~~ math
t = current\_time - epoch\_start
~~~
{: artwork-align="center" }

where *epoch_start* is the time at which the current
congestion avoidance stage starts. *K* is the time period that the
above function takes to increase the current window size to *W<sub>max</sub>*
if there are no further congestion events and is calculated using
the following equation:

~~~ math
K = \sqrt[3]{\frac{W_{max} - cwnd}{C}}
~~~
{: #eq2 artwork-align="center" }

where *cwnd* is the congestion window at the beginning of the current
congestion avoidance stage. *cwnd* is calculated as described in
{{mult-dec}} when a congestion event is detected, although
implementations can further adjust *cwnd* based on other fast
recovery mechanisms. In special cases, if *cwnd* is greater than
*W<sub>max</sub>*, *K* is set to 0.

Upon receiving an ACK during congestion avoidance, CUBIC computes the
*target* congestion window size after the next RTT using {{eq1}} as
follows, where RTT is the smoothed round-trip time. The lower and upper
bounds below ensure that CUBIC's congestion window increase rate is
non-decreasing and is less than the increase rate of slow start.

~~~ math
target = \left\{
\begin{array}{ll}
cwnd                          &
\text{if } \mathrm{W_{cubic}}(t + RTT) < cwnd \\
1.5 * cwnd                    &
\text{if } \mathrm{W_{cubic}}(t + RTT) > 1.5 * cwnd \\
\mathrm{W_{cubic}}(t + RTT)   &
\text{otherwise} \\
\end{array} \right.
~~~
{: artwork-align="center" }

Depending on the value of the current congestion window size *cwnd*,
CUBIC runs in three different modes.

1. The TCP-friendly region, which ensures that CUBIC achieves at
   least the same throughput as Standard TCP.

2. The concave region, if CUBIC is not in the TCP-friendly region
   and *cwnd* is less than *W<sub>max</sub>*.

3. The convex region, if CUBIC is not in the TCP-friendly region and
   *cwnd* is greater than *W<sub>max</sub>*.

Below, we describe the exact actions taken by CUBIC in each region.

## TCP-Friendly Region

Standard TCP performs well in certain types of networks, for example,
under short RTT and small bandwidth (or small BDP) networks. In
these networks, we use the TCP-friendly region to ensure that CUBIC
achieves at least the same throughput as Standard TCP.

The TCP-friendly region is designed according to the analysis
described in {{FHP00}}. The analysis studies the performance of an
Additive Increase and Multiplicative Decrease (AIMD) algorithm with
an additive factor of *{{{α}{}}}<sub>aimd</sub>* (segments per RTT) and a
multiplicative factor of *{{{β}{}}}<sub>aimd</sub>*, denoted by
AIMD(*{{{α}{}}}<sub>aimd</sub>*, *{{{β}{}}}<sub>aimd</sub>*).
Specifically, the average congestion window size of
AIMD(*{{{α}{}}}<sub>aimd</sub>*, *{{{β}{}}}<sub>aimd</sub>*) can be
calculated using {{eq3}}. The analysis shows that
AIMD(*{{{α}{}}}<sub>aimd</sub>*, *{{{β}{}}}<sub>aimd</sub>*) with

~~~ math
α_{aimd} = 3 * \frac{1 - β_{cubic}}{1 + β_{cubic}}
~~~
{: artwork-align="center" }

achieves the same average
window size as Standard TCP that uses AIMD(1, 0.5).

~~~ math
\mathrm{AVG\_AIMD}(α_{aimd}, β_{aimd}) =
    \sqrt{\frac{α_{aimd} * (1 + β_{aimd})}{2 * (1 - β_{aimd}) * p}}
~~~
{: #eq3 artwork-align="center" }

Based on the above analysis, CUBIC uses {{eq4}} to estimate the window
size *W<sub>est</sub>* of AIMD(*{{{α}{}}}<sub>aimd</sub>*,
*{{{β}{}}}<sub>aimd</sub>*) with

~~~ math
\begin{array}{l}
α_{aimd} = 3 * \frac{1 - β_{cubic}}{1 + β_{cubic}} \\
β_{aimd} = β_{cubic} \\
\end{array}
~~~
{: artwork-align="center" }

which achieves the same average window size as Standard TCP. When
receiving an ACK in congestion avoidance (*cwnd* could be greater than
or less than *W<sub>max</sub>*), CUBIC checks whether
W<sub>cubic</sub>(t) is less than *W<sub>est</sub>*. If so, CUBIC is in
the TCP-friendly region and *cwnd* SHOULD be set to *W<sub>est</sub>* at
each reception of an ACK.

*W<sub>est</sub>* is set equal to *cwnd* at the start of the congestion avoidance
stage. After that, on every ACK, *W<sub>est</sub>* is updated using {{eq4}}.

~~~ math
W_{est} = W_{est} + α_{aimd} * \frac{segments\_acked}{cwnd}
~~~
{: #eq4 artwork-align="center" }

Note that once *W<sub>est</sub>* reaches *W<sub>max</sub>*, that is,
*W<sub>est</sub>* >= *W<sub>max</sub>*, *{{{α}{}}}<sub>aimd</sub>* SHOULD be
set to 1 to achieve the same congestion
window size as standard TCP that uses AIMD.

## Concave Region

When receiving an ACK in congestion avoidance, if CUBIC is not in the
TCP-friendly region and *cwnd* is less than *W<sub>max</sub>*, then CUBIC is in the
concave region. In this region, *cwnd* MUST be incremented by

~~~ math
\frac{target - cwnd}{cwnd}
~~~
{: artwork-align="center" }

for each received ACK, where *target* is
calculated as described in {{win-inc}}.

## Convex Region {#convex-region}

When receiving an ACK in congestion avoidance, if CUBIC is not in the
TCP-friendly region and *cwnd* is larger than or equal to *W<sub>max</sub>*, then
CUBIC is in the convex region. The convex region indicates that the
network conditions might have been perturbed since the last
congestion event, possibly implying more available bandwidth after
some flow departures. Since the Internet is highly asynchronous,
some amount of perturbation is always possible without causing a
major change in available bandwidth. In this region, CUBIC is being
very careful by very slowly increasing its window size. The convex
profile ensures that the window increases very slowly at the
beginning and gradually increases its increase rate. We also call
this region the "maximum probing phase" since CUBIC is searching for
a new *W<sub>max</sub>*. In this region, *cwnd* MUST be incremented by

~~~ math
\frac{target - cwnd}{cwnd}
~~~
{: artwork-align="center" }

for each received ACK, where *target* is
calculated as described in {{win-inc}}.

## Multiplicative Decrease {#mult-dec}

When a packet loss is detected by duplicate ACKs or a network
congestion is detected by receiving packets marked with ECN-Echo (ECE),
CUBIC updates its *W<sub>max</sub>* and reduces its *cwnd* and *ssthresh* immediately
as below. For both packet loss and congestion detection through ECN,
the sender MAY employ a fast recovery algorithm to gradually adjust the
congestion window to its new reduced value. Parameter *{{{β}{}}}<sub>cubic</sub>*
SHOULD be set to 0.7.

~~~ math
\begin{array}{ll}
ssthresh = cwnd * β_{cubic} &
\text{// new slow-start threshold} \\
ssthresh = \mathrm{max}(ssthresh, 2) &
\text{// threshold is at least 2 MSS} \\
cwnd = ssthresh &
\text{// window reduction} \\
\end{array}
~~~
{: artwork-align="center" }

A side effect of setting *{{{β}{}}}<sub>cubic</sub>* to a value bigger
than 0.5 is
slower convergence. We believe that while a more adaptive setting of
*{{{β}{}}}<sub>cubic</sub>* could result in faster convergence, it will make the
analysis of CUBIC much harder. This adaptive adjustment of
*{{{β}{}}}<sub>cubic</sub>* is an item for the next version of CUBIC.

## Fast Convergence

To improve the convergence speed of CUBIC, we add a heuristic in
CUBIC. When a new flow joins the network, existing flows in the
network need to give up some of their bandwidth to allow the new flow
some room for growth if the existing flows have been using all the
bandwidth of the network. To speed up this bandwidth release by
existing flows, the following mechanism called "fast convergence"
SHOULD be implemented.

With fast convergence, when a congestion event occurs, we update *W<sub>max</sub>*
as follows before the window reduction as described in {{convex-region}}.

~~~ math
W_{max} = \left\{
\begin{array}{ll}
W_{max} * \frac{1 + β_{cubic}}{2}
& \text{if } cwnd < W_{max}, \text{further reduce } W_{max} \\
cwnd
&\text{otherwise, remember cwnd before reduction} \\
\end{array} \right.
~~~
{: artwork-align="center" }

At a congestion event, if the current *cwnd* is less than *W<sub>max</sub>*, this
indicates that the saturation point experienced by this flow is getting
reduced because of the change in available bandwidth.  Then we allow
this flow to release more bandwidth by reducing *W<sub>max</sub>* further.  This
action effectively lengthens the time for this flow to increase its
congestion window because the reduced *W<sub>max</sub>* forces the flow to have
the plateau earlier.  This allows more time for the new flow to catch
up to its congestion window size.

The fast convergence is designed for network environments with
multiple CUBIC flows. In network environments with only a single
CUBIC flow and without any other traffic, the fast convergence SHOULD
be disabled.

## Timeout

In case of timeout, CUBIC follows Standard TCP to reduce *cwnd*
{{!RFC5681}}, but sets *ssthresh* using *{{{β}{}}}<sub>cubic</sub>* (same as in
{{mult-dec}}) that is different from Standard TCP {{!RFC5681}}.

During the first congestion avoidance after a timeout, CUBIC
increases its congestion window size using {{eq1}}, where t is the
elapsed time since the beginning of the current congestion avoidance,
*K* is set to 0, and *W<sub>max</sub>* is set to the congestion window size at the
beginning of the current congestion avoidance. In addition, for the
tcp-friendliness region, W_est should be set to the congestion window
size at the beginning of the current congestion avoidance.

## Spurious Loss events

For the case where CUBIC reduces its congestion window in response
to detection of packet loss via duplicate ACKs or timeout, there is a
possibility that the missing ACK would arrive after the congestion
window reduction and the corresponding packet retransmission. For
example, packet reordering which is common in networks could trigger
this behavior. A high degree of packet reordering could cause multiple
events of congestion window reduction where spurious losses are
incorrectly interpreted as congestion signals, thus degrading CUBIC's
performance significantly.

When there is a loss event, a CUBIC implementation SHOULD save the current
value of the following variables before the congestion window reduction.

~~~ math
\begin{array}{l}
prior\_cwnd = cwnd \\
prior\_ssthresh = ssthresh \\
prior\_W_{max} = W_{max} \\
prior\_K = K \\
prior\_epoch\_start = epoch\_start \\
prior\_W\_{est} = W_{est} \\
\end{array}
~~~
{: artwork-align="center" }

CUBIC MAY implement an algorithm to detect spurious retransmissions,
such as DSACK {{?RFC3708}}, Forward RTO-Recovery {{?RFC5682}} or
Eifel {{?RFC3522}}. Once a spurious loss event is detected, CUBIC SHOULD
restore the original values of above mentioned variables as follows if
the current *cwnd* is lower than *prior_cwnd*. Restoring to the original
values ensures that CUBIC's performance is similar to what it would be
if there were no spurious losses.

~~~ math
\left.
\begin{array}{l}
cwnd = prior\_cwnd \\
ssthresh = prior\_ssthresh \\
W_{max} = prior\_W_{max} \\
K = prior\_K \\
epoch\_start = prior\_epoch\_start \\
W_{est} = prior\_W_{est} \\
\end{array}
\right\}
\text{if }cwnd < prior\_cwnd
~~~
{: artwork-align="center" }

In rare cases, when the detection happens long after a spurious loss event
and the current *cwnd* is already higher than the *prior_cwnd*, CUBIC SHOULD
continue to use the current and the most recent values of these variables.

## Slow Start

CUBIC MUST employ a slow-start algorithm, when *cwnd* is no more
than *ssthresh*. Among the slow-start algorithms, CUBIC MAY choose the
standard TCP slow start {{!RFC5681}} in general networks, or the limited
slow start {{?RFC3742}} or hybrid slow start {{HR08}} for fast and long-
distance networks.

In the case when CUBIC runs the hybrid slow start {{HR08}}, it may exit
the first slow start without incurring any packet loss and thus *W<sub>max</sub>*
is undefined. In this special case, CUBIC switches to congestion
avoidance and increases its congestion window size using {{eq1}}, where
t is the elapsed time since the beginning of the current congestion
avoidance, *K* is set to 0, and *W<sub>max</sub>* is set to the congestion window
size at the beginning of the current congestion avoidance.

# Discussion {#discussion}

In this section, we further discuss the safety features of CUBIC
following the guidelines specified in {{!RFC5033}}.

With a deterministic loss model where the number of packets between
two successive packet losses is always *1/p*, CUBIC always operates
with the concave window profile, which greatly simplifies the
performance analysis of CUBIC. The average window size of CUBIC can
be obtained by the following function:

~~~ math
AVG\_W_{cubic} = \sqrt[4]{\frac{C * (3 + β_{cubic})}{4 * (1 - β_{cubic})}} * \frac{\sqrt[3]{RTT^4}}{\sqrt[3]{p^4}}
~~~
{: #eq5 artwork-align="center" }

With *{{{β}{}}}<sub>cubic</sub>* set to 0.7, the above formula is reduced to:

~~~ math
AVG\_W_{cubic} = \sqrt[4]{\frac{C * 3.7}{1.2}} *
                 \frac{\sqrt[3]{RTT^4}}{\sqrt[3]{p^4}}
~~~
{: #eq6 artwork-align="center" }

We will determine the value of *C* in the following subsection using
{{eq6}}.

## Fairness to Standard TCP

In environments where Standard TCP is able to make reasonable use of
the available bandwidth, CUBIC does not significantly change this
state.

Standard TCP performs well in the following two types of networks:

1. networks with a small bandwidth-delay product (BDP)

2. networks with a short RTTs, but not necessarily a small BDP

CUBIC is designed to behave very similarly to Standard TCP in the
above two types of networks. The following two tables show the
average window sizes of Standard TCP, HSTCP, and CUBIC. The average
window sizes of Standard TCP and HSTCP are from {{?RFC3649}}. The
average window size of CUBIC is calculated using {{eq6}} and the CUBIC
TCP-friendly region for three different values of *C*.

| Loss Rate P | TCP | HSTCP | CUBIC (C=0.04) | CUBIC (C=0.4) | CUBIC (C=4) |
| ---:| ---:| ---:| ---:| ---:| ---:|
| 1.0e-02 | 12 | 12 | 12 | 12 | 12 |
| 1.0e-03 | 38 | 38 | 38 | 38 | 59 |
| 1.0e-04 | 120 | 263 | 120 | 187 | 333 |
| 1.0e-05 | 379 | 1795 | 593 | 1054 | 1874 |
| 1.0e-06 | 1200 | 12280 | 3332 | 5926 | 10538 |
| 1.0e-07 | 3795 | 83981 | 18740 | 33325 | 59261 |
| 1.0e-08 | 12000 | 574356 | 105383 | 187400 | 333250 |
{: #tab1 title="Standard TCP, HSTCP, and CUBIC with RTT = 0.1 seconds"}

{{tab1}} describes the response function of Standard TCP, HSTCP, and
CUBIC in networks with RTT = 0.1 seconds. The average window size is
in MSS-sized segments.

| Loss Rate P | TCP | HSTCP | CUBIC (C=0.04) | CUBIC (C=0.4) | CUBIC (C=4) |
| ---:| ---:| ---:| ---:| ---:| ---:|
| 1.0e-02 | 12 | 12 | 12 | 12 | 12 |
| 1.0e-03 | 38 | 38 | 38 | 38 | 38 |
| 1.0e-04 | 120 | 263 | 120 | 120 | 120 |
| 1.0e-05 | 379 | 1795 | 379 | 379 | 379 |
| 1.0e-06 | 1200 | 12280 | 1200 | 1200 | 1874 |
| 1.0e-07 | 3795 | 83981 | 3795 | 5926 | 10538 |
| 1.0e-08 | 12000 | 574356 | 18740 | 33325 | 59261 |
{: #tab2 title="Standard TCP, HSTCP, and CUBIC with RTT = 0.01 seconds"}

{{tab2}} describes the response function of Standard TCP, HSTCP, and
CUBIC in networks with RTT = 0.01 seconds. The average window size
is in MSS-sized segments.

Both tables show that CUBIC with any of these three *C* values is more
friendly to TCP than HSTCP, especially in networks with a short RTT
where TCP performs reasonably well. For example, in a network with
RTT = 0.01 seconds and p=10^-6, TCP has an average window of 1200
packets. If the packet size is 1500 bytes, then TCP can achieve an
average rate of 1.44 Gbps. In this case, CUBIC with *C*=0.04 or *C*=0.4
achieves exactly the same rate as Standard TCP, whereas HSTCP is
about ten times more aggressive than Standard TCP.

We can see that *C* determines the aggressiveness of CUBIC in competing
with other congestion control algorithms for bandwidth. CUBIC is
more friendly to Standard TCP, if the value of *C* is lower. However,
we do not recommend setting *C* to a very low value like 0.04, since
CUBIC with a low *C* cannot efficiently use the bandwidth in long RTT
and high-bandwidth networks. Based on these observations and our
experiments, we find *C*=0.4 gives a good balance between TCP-
friendliness and aggressiveness of window increase. Therefore, *C*
SHOULD be set to 0.4. With *C* set to 0.4, {{eq6}} is reduced to:

~~~ math
AVG\_W_{cubic} = 1.054 * \frac{\sqrt[3]{RTT^4}}{\sqrt[3]{p^4}}
~~~
{: #eq7 artwork-align="center" }

{{eq7}} is then used in the next subsection to show the scalability of
CUBIC.

## Using Spare Capacity

CUBIC uses a more aggressive window increase function than Standard
TCP under long RTT and high-bandwidth networks.

The following table shows that to achieve the 10 Gbps rate, Standard
TCP requires a packet loss rate of 2.0e-10, while CUBIC requires a
packet loss rate of 2.9e-8.

| Throughput (Mbps) | Average W | TCP P   | HSTCP P | CUBIC P |
|------------------:|----------:|--------:|--------:|--------:|
|                 1 |       8.3 | 2.0e-2  | 2.0e-2  | 2.0e-2  |
|                10 |      83.3 | 2.0e-4  | 3.9e-4  | 2.9e-4  |
|               100 |     833.3 | 2.0e-6  | 2.5e-5  | 1.4e-5  |
|              1000 |    8333.3 | 2.0e-8  | 1.5e-6  | 6.3e-7  |
|             10000 |   83333.3 | 2.0e-10 | 1.0e-7  | 2.9e-8  |
{: #tab3 title="Required packet loss rate for Standard TCP,
HSTCP, and CUBIC to achieve a certain throughput"}

{{tab3}} describes the required packet loss rate for Standard TCP,
HSTCP, and CUBIC to achieve a certain throughput. We use 1500-byte
packets and an RTT of 0.1 seconds.

Our test results in {{HKLRX06}} indicate that CUBIC uses the spare
bandwidth left unused by existing Standard TCP flows in the same
bottleneck link without taking away much bandwidth from the existing
flows.

## Difficult Environments

CUBIC is designed to remedy the poor performance of TCP in fast and
long-distance networks.

## Investigating a Range of Environments

CUBIC has been extensively studied by using both NS-2 simulation and
test-bed experiments covering a wide range of network environments.
More information can be found in {{HKLRX06}}.

Same as Standard TCP, CUBIC is a loss-based congestion control
algorithm. Because CUBIC is designed to be more aggressive (due to a
faster window increase function and bigger multiplicative decrease
factor) than Standard TCP in fast and long-distance networks, it can
fill large drop-tail buffers more quickly than Standard TCP and
increase the risk of a standing queue {{?RFC8511}}. In this case, proper
queue sizing and management {{!RFC7567}} could be used to reduce the
packet queuing delay.

## Protection against Congestion Collapse

With regard to the potential of causing congestion collapse, CUBIC
behaves like Standard TCP since CUBIC modifies only the window
adjustment algorithm of TCP. Thus, it does not modify the ACK
clocking and Timeout behaviors of Standard TCP.

## Fairness within the Alternative Congestion Control Algorithm

CUBIC ensures convergence of competing CUBIC flows with the same RTT
in the same bottleneck links to an equal throughput. When competing
flows have different RTTs, their throughput ratio is linearly
proportional to the inverse of their RTT ratios. This is true
independent of the level of statistical multiplexing in the link.

## Performance with Misbehaving Nodes and Outside Attackers

This is not considered in the current CUBIC.

## Behavior for Application-Limited Flows

CUBIC does not raise its congestion window size if the flow is
currently limited by the application instead of the congestion
window. In case of long periods when *cwnd* has not been updated due
to the application rate limit, such as idle periods, t in {{eq1}} MUST
NOT include these periods; otherwise, W<sub>cubic</sub>(t) might be very high
after restarting from these periods.

## Responses to Sudden or Transient Events

If there is a sudden congestion, a routing change, or a mobility
event, CUBIC behaves the same as Standard TCP.

## Incremental Deployment

CUBIC requires only the change of TCP senders, and it does not make
any changes to TCP receivers. That is, a CUBIC sender works
correctly with the Standard TCP receivers. In addition, CUBIC does
not require any changes to the routers and does not require any
assistance from the routers.

# Security Considerations

This proposal makes no changes to the underlying security of TCP.
More information about TCP security concerns can be found in
{{!RFC5681}}.

# IANA Considerations

This document does not require any IANA actions.

--- back

# Acknowledgements

Richard Scheffenegger and Alexander Zimmermann originally co-authored
{{?RFC8312}}.

<!-- Anyone else to acknowledge? -->

# Changes from RFC8312

<!-- For future PRs, please include a bullet below that summarizes the change
     and point to the PR number. -->

## Since draft-eggert-tcpm-rfc8312bis-00

- acknowledge former co-authors
  ([#15](https://github.com/NTAP/rfc8312bis/issues/15))
- prevent *cwnd* from becoming less than two
  ([#7](https://github.com/NTAP/rfc8312bis/issues/7))
- add list of variables and constants
  ([#5](https://github.com/NTAP/rfc8312bis/issues/5),
  [#6](https://github.com/NTAP/rfc8312bis/issues/5))
- update *K*'s definition and add bounds for CUBIC *target* *cwnd*
  ([#1](https://github.com/NTAP/rfc8312bis/issues/1),
  [#14](https://github.com/NTAP/rfc8312bis/issues/14))
- update *W<sub>est</sub>* to use AIMD approach
  ([#20](https://github.com/NTAP/rfc8312bis/issues/20))
- set <!-- xml2rfc cannot handdle this here: {{{α}{}}} -->alpha<sub>aimd</sub>
  to 1 once *W<sub>est</sub>* reaches *W<sub>max</sub>*
  ([#2](https://github.com/NTAP/rfc8312bis/issues/2))
- add Vidhi as co-author ([#17](https://github.com/NTAP/rfc8312bis/issues/17))
- note for fast recovery during *cwnd* decrease due to congestion event
  ([#11](https://github.com/NTAP/rfc8312bis11/issues/11))
- add section for Spurious Loss events
  ([#23](https://github.com/NTAP/rfc8312bis/issues/23))
- initialize *W<sub>est</sub>* after timeout and remove variable
  W<sub>last_max</sub> ([#28](https://github.com/NTAP/rfc8312bis/issues/28))

## Since RFC8312

- converted to markdown and xml2rfc v3
- updated references (as part of the conversion)
- updated author information
- various whitespace changes
- move to Standards Track
