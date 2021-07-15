---

title: CUBIC for Fast and Long-Distance Networks
abbrev: CUBIC
docname: draft-ietf-tcpm-rfc8312bis-latest
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
  name: Injong Rhee
  org: Bowery Farming
  abbrev: Bowery
  street: 151 W 26TH Street, 12TH Floor
  city: New York
  region: NY
  code: 10001
  country: USA
  email: injongrhee@gmail.com
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
    date: 2008-3
    seriesinfo:
      International Workshop on: Protocols for Fast Long-Distance Networks
    author:
    - ins: S. Ha
    - ins: I. Rhee
    target: "http://www.hep.man.ac.uk/g/GDARN-IT/pfldnet2008/paper/Sangate_Ha%20Final.pdf"

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

  SXEZ19:
    title:
      Model-Agnostic and Efficient Exploration of Numerical State Space of
      Real-World TCP Congestion Control Implementations
    date: 2019-2
    seriesinfo:
      USENIX NSDI: 2019
    author:
    - name: Wei Sun
    - name: Lisong Xu
    - name: Sebastian Elbaum
    - name: Di Zhao
    target: "https://www.usenix.org/system/files/nsdi19-sun.pdf"

  CEHRX07:  DOI.10.1109/INFCOM.2007.111
  HRX08:    DOI.10.1145/1400097.1400105
  K03:      DOI.10.1145/956981.956989

--- abstract

CUBIC is a standard TCP congestion control algorithm that uses a cubic
function instead of the linear window increase function on the sender
side to improve scalability and stability over fast and long-distance
networks. CUBIC has been adopted as the default TCP congestion control
algorithm by the Linux, Windows, and Apple stacks.

This document updates the specification of CUBIC to include
algorithmic improvements based on these implementations and recent
academic work. Based on the extensive deployment experience with
CUBIC, it also moves the specification to the Standards Track,
obsoleting {{?RFC8312}}.

--- note_Note_to_Readers

Discussion of this draft takes place on the [TCPM working group
mailing list](mailto:tcpm@ietf.org), which is archived at
[](https://mailarchive.ietf.org/arch/browse/tcpm/).

Working Group information can be found at
[](https://datatracker.ietf.org/wg/tcpm/); source code and issues list
for this draft can be found at [](https://github.com/NTAP/rfc8312bis).

--- note_Note_to_the_RFC_Editor

xml2rfc currently renders `<em></em>` in the XML by surrounding the
corresponding text with underscores. This is highly distracting;
please manually remove the underscores when doing the final edits to
the text version of this document.

(There is an issue open against xml2rfc to stop doing this in the
future: https://trac.tools.ietf.org/tools/xml2rfc/trac/ticket/596)

Also, please manually change "Figure" to "Equation" for all artwork
with anchors beginning with "eq" - xml2rfc doesn't seem to be able to
do this.

--- middle

# Introduction

CUBIC has been adopted as the default TCP congestion control algorithm
in the Linux, Windows, and Apple stacks, and has been used and
deployed globally. Extensive, decade-long deployment experience in
vastly different Internet scenarios has convincingly demonstrated that
CUBIC is safe for deployment on the global Internet and delivers
substantial benefits over traditional AIMD congestion control. It is
therefore to be regarded as the current standard for TCP congestion
control. CUBIC can also be used for other transport protocols such as
QUIC {{?RFC9000}} and SCTP {{?RFC4960}} as a default congestion controller.

The design of CUBIC was motivated by the well-documented problem
traditional TCP has with  low utilization over fast and long-distance
networks {{K03}}{{?RFC3649}}. This problem arises from a slow increase
of the congestion window following a congestion event in a network
with a large bandwidth-delay product (BDP). {{HKLRX06}} indicates that
this problem is frequently observed even in the range of congestion
window sizes over several hundreds of packets. This problem is equally
applicable to all Reno-style TCP standards and their variants,
including TCP-Reno {{!RFC5681}}, TCP-NewReno {{!RFC6582}}{{!RFC6675}},
SCTP {{?RFC4960}}, and TFRC {{!RFC5348}}, which use the same linear
increase function for window growth. We refer to all Reno-style TCP
standards and their variants collectively as "AIMD TCP" below because
they use the Additive Increase and Multiplicative Decrease algorithm
(AIMD).

CUBIC, originally proposed in {{HRX08}}, is a modification to the
congestion control algorithm of traditional AIMD TCP to remedy this
problem. This document describes the most recent specification of
CUBIC. Specifically, CUBIC uses a cubic function instead of the linear
window increase function of AIMD TCP to improve scalability and
stability under fast and long-distance networks.

Binary Increase Congestion Control (BIC-TCP) {{XHR04}}, a predecessor
of CUBIC, was selected as the default TCP congestion control algorithm
by Linux in the year 2005 and had been used for several years by the
Internet community at large.

CUBIC uses a similar window increase function as BIC-TCP and is
designed to be less aggressive and fairer to AIMD TCP in bandwidth
usage than BIC-TCP while maintaining the strengths of BIC-TCP such as
stability, window scalability, and round-trip time (RTT) fairness.

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
: To be AIMD-friendly, CUBIC is designed to behave like AIMD TCP in
  networks with short RTTs and small bandwidth where AIMD TCP
  performs well.

Principle 3:
: For RTT-fairness, CUBIC is designed to achieve linear bandwidth
  sharing among flows with different RTTs.

Principle 4:
: CUBIC appropriately sets its multiplicative window decrease factor
  in order to balance between the scalability and convergence speed.

## Principle 1 for the CUBIC Increase Function

For better network utilization and stability, CUBIC {{HRX08}} uses a
cubic window increase function in terms of the elapsed time from the
last congestion event. While most alternative congestion control
algorithms to AIMD TCP increase the congestion window using convex
functions, CUBIC uses both the concave and convex profiles of a cubic
function for window growth.

After a window reduction in response to a congestion event is detected
by duplicate ACKs or Explicit Congestion Notification-Echo (ECN-Echo,
ECE) ACKs {{!RFC3168}}, CUBIC remembers the congestion window size
where it received the congestion event and performs a multiplicative
decrease of the congestion window. When CUBIC enters into congestion
avoidance, it starts to increase the congestion window using the
concave profile of the cubic function. The cubic function is set to
have its plateau at the remembered congestion window size, so that the
concave window increase continues until then. After that, the cubic
function turns into a convex profile and the convex window increase
begins.

This style of window adjustment (concave and then convex) improves the
algorithm stability while maintaining high network utilization
{{CEHRX07}}. This is because the window size remains almost constant,
forming a plateau around the remembered congestion window size of the
last congestion event, where network utilization is deemed highest.
Under steady state, most window size samples of CUBIC are close to
that remembered congestion window size, thus promoting high network
utilization and stability.

Note that congestion control algorithms that only use convex functions
to increase the congestion window size have their maximum increments
around the remembered congestion window size of the last congestion
event, and thus introduce many packet bursts around the
saturation point of the network, likely causing frequent global loss
synchronizations.

## Principle 2 for AIMD Friendliness

CUBIC promotes per-flow fairness to AIMD TCP. Note that AIMD TCP
performs well over paths with short RTTs and small bandwidths (or
small BDPs). There is only a scalability problem in networks with long
RTTs and large bandwidths (or large BDPs).

A congestion control algorithm designed to be friendly to AIMD TCP on
a per-flow basis must increase its congestion window less aggressively
in small BDP networks than in large BDP networks.

The aggressiveness of CUBIC mainly depends on the maximum window size
before a window reduction, which is smaller in small-BDP networks than
in large-BDP networks. Thus, CUBIC increases its congestion window
less aggressively in small-BDP networks than in large-BDP networks.

Furthermore, in cases when the cubic function of CUBIC would increase
the congestion window less aggressively than AIMD TCP, CUBIC simply
follows the window size of AIMD TCP to ensure that CUBIC achieves at
least the same throughput as AIMD TCP in small-BDP networks. We call
this region where CUBIC behaves like AIMD TCP the "AIMD-friendly
region".

## Principle 3 for RTT Fairness

Two CUBIC flows with different RTTs have a throughput ratio that is
linearly proportional to the inverse of their RTT ratio, where the
throughput of a flow is approximately the size of its congestion
window divided by its RTT.

Specifically, CUBIC maintains a window increase rate independent of
RTTs outside the AIMD-friendly region, and thus flows with
different RTTs have similar congestion window sizes under steady state
when they operate outside the AIMD-friendly region.

This notion of a linear throughput ratio is similar to that of AIMD
TCP under high statistical multiplexing where packet loss is
independent of individual flow rates. However, under low statistical
multiplexing, the throughput ratio of AIMD TCP flows with different
RTTs is quadratically proportional to the inverse of their RTT ratio
{{XHR04}}.

CUBIC always ensures a linear throughput ratio independent of the
amount of statistical multiplexing. This is an improvement over AIMD
TCP. While there is no consensus on particular throughput ratios for
different RTT flows, we believe that over wired Internet paths, use of
a linear throughput ratio seems more reasonable than equal throughputs
(i.e., the same throughput for flows with different RTTs) or a
higher-order throughput ratio (e.g., a quadratical throughput ratio of
AIMD TCP under low statistical multiplexing environments).

## Principle 4 for the CUBIC Decrease Factor

To balance between scalability and convergence speed, CUBIC sets the
multiplicative window decrease factor to 0.7, whereas AIMD TCP uses
0.5.

While this improves the scalability of CUBIC, a side effect of this
decision is slower convergence, especially under low statistical
multiplexing. This design choice is following the observation that
HighSpeed TCP (HSTCP) {{?RFC3649}} and other approaches (e.g.,
{{GV02}}) made: the current Internet becomes more asynchronous with
less frequent loss synchronizations under high statistical
multiplexing.

In such environments, even strict Multiplicative-Increase
Multiplicative-Decrease (MIMD) can converge. CUBIC flows with the same
RTT always converge to the same throughput independent of statistical
multiplexing, thus achieving intra-algorithm fairness. We also find
that in environments with sufficient statistical multiplexing, the
convergence speed of CUBIC is reasonable.

# CUBIC Congestion Control

In this section, we discuss how the congestion window is updated
during the different stages of the CUBIC congestion controller.

## Definitions

The unit of all window sizes in this document is segments of the
maximum segment size (MSS), and the unit of all times is seconds.
Implementations can use bytes to express window sizes, which would
require factoring in the maximum segment size wherever necessary
and replacing *segments_acked* with the number of bytes
acknowledged in {{eq4}}.

### Constants of Interest

{{{β}{}}}*<sub>cubic</sub>*:
CUBIC multiplication decrease factor as described in {{mult-dec}}.

{{{α}{}}}*<sub>cubic</sub>*:
CUBIC additive increase factor used in AIMD-friendly region
as described in {{aimd-friendly}}.

*C*:
constant that determines the aggressiveness of CUBIC in competing with
other congestion control algorithms in high BDP networks. Please see
{{discussion}} for more explanation on how it is set. The unit for *C*
is

~~~ math
\frac{segment}{second^3}
~~~
{: artwork-align="center" }

### Variables of Interest

This section defines the variables required to implement CUBIC:

*RTT*:
Smoothed round-trip time in seconds, calculated as described in
{{!RFC6298}}.

*cwnd*:
Current congestion window in segments.

*ssthresh*:
Current slow start threshold in segments.

*W<sub>max</sub>*:
Size of *cwnd* in segments just before *cwnd* was reduced in the last
congestion event when fast convergence is disabled. However, if fast
convergence is enabled, the size may be further reduced based on the
current saturation point.

*K*:
The time period in seconds it takes to increase the congestion window
size at the beginning of the current congestion avoidance stage to
*W<sub>max</sub>*.

*current_time*:
Current time of the system in seconds.

*epoch<sub>start</sub>*:
The time in seconds at which the current congestion avoidance stage
started.

*cwnd<sub>start</sub>*:
The *cwnd* at the beginning of the current congestion avoidance stage,
i.e., at time *epoch<sub>start</sub>*.

W<sub>cubic</sub>(*t*):
The congestion window in segments at time *t* in seconds
based on the cubic increase function, as described in {{win-inc}}.

*target*:
Target value of congestion window in segments after the next RTT,
that is, W<sub>cubic</sub>(*t* + *RTT*), as described in {{win-inc}}.

*W<sub>est</sub>*:
An estimate for the congestion window in segments in the AIMD-friendly
region, that is, an estimate for the congestion window of AIMD TCP.

*segments_acked*:
Number of MSS-sized segments acked when an ACK is received. This
number will be a decimal value when an ACK acknowledges an amount of data
that is not MSS-sized. Specifically, it can be less than 1 when
an ACK acknowledges a segment smaller than the MSS.

## Window Increase Function {#win-inc}

CUBIC maintains the acknowledgment (ACK) clocking of AIMD TCP by
increasing the congestion window only at the reception of an ACK. It
does not make any changes to the TCP Fast Recovery and Fast Retransmit
algorithms {{!RFC6582}}{{!RFC6675}}.

During congestion avoidance after a congestion event where a packet
loss is detected by duplicate ACKs or by receiving packets carrying
ECE flags {{!RFC3168}}, CUBIC changes the window increase function of
AIMD TCP.

CUBIC uses the following window increase function:

~~~ math
\mathrm{W_{cubic}}(t) = C * (t - K)^3 + W_{max}
~~~
{: #eq1 artwork-align="center" }

where *t* is the elapsed time in seconds from the beginning of the
current congestion avoidance stage, that is,

~~~ math
t = current\_time - epoch_{start}
~~~
{: artwork-align="center" }

and where *epoch<sub>start</sub>* is the time at which the current
congestion avoidance stage starts. *K* is the time period that the
above function takes to increase the congestion window size at the
beginning of the current congestion avoidance stage to
*W<sub>max</sub>* if there are no further congestion events and is
calculated using the following equation:

~~~ math
K = \sqrt[3]{\frac{W_{max} - cwnd_{start}}{C}}
~~~
{: #eq2 artwork-align="center" }

where *cwnd<sub>start</sub>* is the congestion window at the beginning
of the current congestion avoidance stage. For example, right after a
congestion event, *cwnd<sub>start</sub>* is equal to the new cwnd
calculated as described in {{mult-dec}}.

Upon receiving an ACK during congestion avoidance, CUBIC computes the
*target* congestion window size after the next *RTT* using {{eq1}} as
follows, where *RTT* is the smoothed round-trip time. The lower and
upper bounds below ensure that CUBIC's congestion window increase rate
is non-decreasing and is less than the increase rate of slow start.

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
CUBIC runs in three different regions:

1. The AIMD-friendly region, which ensures that CUBIC achieves at
   least the same throughput as AIMD TCP.

2. The concave region, if CUBIC is not in the AIMD-friendly region
   and *cwnd* is less than *W<sub>max</sub>*.

3. The convex region, if CUBIC is not in the AIMD-friendly region and
   *cwnd* is greater than *W<sub>max</sub>*.

Below, we describe the exact actions taken by CUBIC in each region.

## AIMD-Friendly Region {#aimd-friendly}

AIMD TCP performs well in certain types of networks, for example,
under short RTTs and small bandwidths (or small BDPs). In these
networks, CUBIC remains in the AIMD-friendly region to achieve at
least the same throughput as AIMD TCP.

The AIMD-friendly region is designed according to the analysis in
{{FHP00}}, which studies the performance of an AIMD algorithm with an
additive factor of {{{α}{}}} (segments per *RTT*) and
a multiplicative factor of {{{β}{}}}, denoted by
AIMD({{{α}{}}}, {{{β}{}}}). *p* is the packet loss rate.
Specifically, the average congestion window size of
AIMD({{{α}{}}}, {{{β}{}}}) can be
calculated using {{eq3}}.

~~~ math
\mathrm{AVG\_AIMD}(α, β) =
    \sqrt{\frac{α * (1 + β)}{2 * (1 - β) * p}}
~~~
{: #eq3 artwork-align="center" }

By the same analysis, to achieve the same average window size as AIMD TCP
that uses AIMD(1, 0.5), {{{α}{}}} must be equal to,

~~~ math
3 * \frac{1 - β}{1 + β}
~~~
{: artwork-align="center" }

Thus, CUBIC uses {{eq4}} to estimate the window
size *W<sub>est</sub>* in the AIMD-friendly region with

~~~ math
α_{cubic} = 3 * \frac{1 - β_{cubic}}{1 + β_{cubic}} \\
~~~
{: artwork-align="center" }

which achieves the same average window size as AIMD TCP. When
receiving an ACK in congestion avoidance (where *cwnd* could be
greater than or less than *W<sub>max</sub>*), CUBIC checks whether
W<sub>cubic</sub>(*t*) is less than *W<sub>est</sub>*. If so, CUBIC is
in the AIMD-friendly region and *cwnd* SHOULD be set to
*W<sub>est</sub>* at each reception of an ACK.

*W<sub>est</sub>* is set equal to *cwnd<sub>start</sub>* at the start
of the congestion avoidance stage. After that, on every ACK,
*W<sub>est</sub>* is updated using {{eq4}}. Note that, this equation
is for a connection in which Appropriate Byte Counting (ABC) {{!RFC3465}}
is disabled. For a connection with ABC enabled, this equation should be
adjusted using the number of acknowledged  bytes instead of acknowledged
segments. Also note that, this equation works for connections with
Delayed ACK {{!RFC5681}} both enabled and disabled, as
*segments_acked* will be different based on
the segments actually acknowledged by an ACK.  

~~~ math
W_{est} = W_{est} + α_{cubic} * \frac{segments\_acked}{cwnd}
~~~
{: #eq4 artwork-align="center" }

Note that once *W<sub>est</sub>* reaches *W<sub>max</sub>*, that is,
*W<sub>est</sub>* >= *W<sub>max</sub>*, CUBIC needs to start probing to
determine the new value of *W<sub>max</sub>*. At this point,
{{{α}{}}}*<sub>cubic</sub>* SHOULD be set to 1 to ensure that
CUBIC can achieve the same congestion window increment as AIMD
TCP, which uses AIMD(1, 0.5).

## Concave Region

When receiving an ACK in congestion avoidance, if CUBIC is not in the
AIMD-friendly region and *cwnd* is less than *W<sub>max</sub>*, then
CUBIC is in the concave region. In this region, *cwnd* MUST be
incremented by

~~~ math
\frac{target - cwnd}{cwnd}
~~~
{: artwork-align="center" }

for each received ACK, where *target* is calculated as described in
{{win-inc}}.

## Convex Region

When receiving an ACK in congestion avoidance, if CUBIC is not in the
AIMD-friendly region and *cwnd* is larger than or equal to
*W<sub>max</sub>*, then CUBIC is in the convex region.

The convex region indicates that the network conditions might have
changed since the last congestion event, possibly implying more
available bandwidth after some flow departures. Since the Internet is
highly asynchronous, some amount of perturbation is always possible
without causing a major change in available bandwidth.

Unless it is overridden by the AIMD window increase, CUBIC is very
careful in this region. The convex profile aims to
increase the window very slowly at the beginning when *cwnd* is
around *W<sub>max</sub>* and then gradually increases its rate of increase.
We also call this region the "maximum probing phase", since CUBIC is
searching for a new *W<sub>max</sub>*. In this region, *cwnd* MUST be
incremented by

~~~ math
\frac{target - cwnd}{cwnd}
~~~
{: artwork-align="center" }

for each received ACK, where *target* is calculated as described in
{{win-inc}}.

## Multiplicative Decrease {#mult-dec}

When a packet loss is detected by duplicate ACKs or by receiving
packets carrying ECE flags, CUBIC updates *W<sub>max</sub>* and
reduces *cwnd* and *ssthresh* immediately as described below. An
implementation MAY set a smaller *ssthresh* than suggested below to
accommodate rate-limited applications as described in {{?RFC7661}}.
For both packet loss and congestion detection through ECN, the sender
MAY employ a Fast Recovery algorithm to gradually adjust the
congestion window to its new reduced *ssthresh* value. The parameter
{{{β}{}}}*<sub>cubic</sub>* SHOULD be set to 0.7.

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

A side effect of setting {{{β}{}}}*<sub>cubic</sub>* to a value bigger
than 0.5 is slower convergence. We believe that while a more adaptive
setting of {{{β}{}}}*<sub>cubic</sub>* could result in faster
convergence, it will make the analysis of CUBIC much harder.

## Fast Convergence

To improve convergence speed, CUBIC uses a heuristic. When a new flow
joins the network, existing flows need to give up some of their
bandwidth to allow the new flow some room for growth, if the existing
flows have been using all the network bandwidth. To speed up this
bandwidth release by existing flows, the following "Fast Convergence"
mechanism SHOULD be implemented.

With Fast Convergence, when a congestion event occurs, we update
*W<sub>max</sub>* as follows, before the window reduction as described
in {{mult-dec}}.

~~~ math
W_{max} = \left\{
\begin{array}{ll}
cwnd * \frac{1 + β_{cubic}}{2}
& \text{if } cwnd < W_{max} \text{ and fast convergence is enabled},\\
& \text{further reduce } W_{max} \\
cwnd
&\text{otherwise, remember cwnd before reduction} \\
\end{array} \right.
~~~
{: artwork-align="center" }

At a congestion event, if the current *cwnd* is less than
*W<sub>max</sub>*, this indicates that the saturation point
experienced by this flow is getting reduced because of a change in
available bandwidth. Then we allow this flow to release more bandwidth
by reducing *W<sub>max</sub>* further. This action effectively
lengthens the time for this flow to increase its congestion window,
because the reduced *W<sub>max</sub>* forces the flow to plateau
earlier. This allows more time for the new flow to catch up to its
congestion window size.

Fast Convergence is designed for network environments with multiple
CUBIC flows. In network environments with only a single CUBIC flow and
without any other traffic, Fast Convergence SHOULD be disabled.

## Timeout

In case of a timeout, CUBIC follows AIMD TCP to reduce *cwnd*
{{!RFC5681}}, but sets *ssthresh* using {{{β}{}}}*<sub>cubic</sub>*
(same as in {{mult-dec}}) in a way that is different from AIMD TCP
{{!RFC5681}}.

During the first congestion avoidance stage after a timeout, CUBIC
increases its congestion window size using {{eq1}}, where *t* is the
elapsed time since the beginning of the current congestion avoidance,
*K* is set to 0, and *W<sub>max</sub>* is set to the congestion window
size at the beginning of the current congestion avoidance stage. In
addition, for the AIMD-friendly region, *W<sub>est</sub>* SHOULD be
set to the congestion window size at the beginning of the current
congestion avoidance.

## Spurious Congestion Events

In cases where CUBIC reduces its congestion window in response to
having detected packet loss via duplicate ACKs or timeouts, there is a
possibility that the missing ACK would arrive after the congestion
window reduction and a corresponding packet retransmission. For
example, packet reordering could trigger this behavior. A high degree
of packet reordering could cause multiple congestion window reduction
events, where spurious losses are incorrectly interpreted as
congestion signals, thus degrading CUBIC's performance significantly.

When there is a congestion event, a CUBIC implementation SHOULD save
the current value of the following variables before the congestion
window reduction.

~~~ math
\begin{array}{l}
prior\_cwnd = cwnd \\
prior\_ssthresh = ssthresh \\
prior\_W_{max} = W_{max} \\
prior\_K = K \\
prior\_epoch_{start} = epoch_{start} \\
prior\_W\_{est} = W_{est} \\
\end{array}
~~~
{: artwork-align="center" }

CUBIC MAY implement an algorithm to detect spurious retransmissions,
such as DSACK {{?RFC3708}}, Forward RTO-Recovery {{?RFC5682}} or Eifel
{{?RFC3522}}. Once a spurious congestion event is detected, CUBIC
SHOULD restore the original values of above mentioned variables as
follows if the current *cwnd* is lower than *prior_cwnd*. Restoring
the original values ensures that CUBIC's performance is similar to
what it would be without spurious losses.

~~~ math
\left.
\begin{array}{l}
cwnd = prior\_cwnd \\
ssthresh = prior\_ssthresh \\
W_{max} = prior\_W_{max} \\
K = prior\_K \\
epoch_{start} = prior\_epoch_{start} \\
W_{est} = prior\_W_{est} \\
\end{array}
\right\}
\text{if }cwnd < prior\_cwnd
~~~
{: artwork-align="center" }

In rare cases, when the detection happens long after a spurious loss
event and the current *cwnd* is already higher than *prior_cwnd*,
CUBIC SHOULD continue to use the current and the most recent values of
these variables.

## Slow Start

CUBIC MUST employ a slow-start algorithm, when *cwnd* is no more than
*ssthresh*. Among the slow-start algorithms, CUBIC MAY choose the AIMD
TCP slow start {{!RFC5681}} in general networks, or the limited slow
start {{?RFC3742}} or hybrid slow start {{HR08}} for fast and
long-distance networks.

When CUBIC uses hybrid slow start {{HR08}}, it may exit the first slow
start without incurring any packet loss and thus *W<sub>max</sub>* is
undefined. In this special case, CUBIC switches to congestion
avoidance and increases its congestion window size using {{eq1}},
where *t* is the elapsed time since the beginning of the current
congestion avoidance, *K* is set to 0, and *W<sub>max</sub>* is set to
the congestion window size at the beginning of the current congestion
avoidance stage.

# Discussion {#discussion}

In this section, we further discuss the safety features of CUBIC
following the guidelines specified in {{!RFC5033}}.

With a deterministic loss model where the number of packets between
two successive packet losses is always *1/p*, CUBIC always operates
with the concave window profile, which greatly simplifies the
performance analysis of CUBIC. The average window size of CUBIC can be
obtained by the following function:

~~~ math
AVG\_W_{cubic} = \sqrt[4]{\frac{C * (3 + β_{cubic})}{4 * (1 - β_{cubic})}} * \frac{\sqrt[3]{RTT^4}}{\sqrt[3]{p^4}}
~~~
{: #eq5 artwork-align="center" }

With {{{β}{}}}*<sub>cubic</sub>* set to 0.7, the above formula reduces
to:

~~~ math
AVG\_W_{cubic} = \sqrt[4]{\frac{C * 3.7}{1.2}} *
                 \frac{\sqrt[3]{RTT^4}}{\sqrt[3]{p^4}}
~~~
{: #eq6 artwork-align="center" }

We will determine the value of *C* in the following subsection using
{{eq6}}.

## Fairness to AIMD TCP

In environments where AIMD TCP is able to make reasonable use of the
available bandwidth, CUBIC does not significantly change this state.

AIMD TCP performs well in the following two types of networks:

1. networks with a small bandwidth-delay product (BDP)

2. networks with a short RTTs, but not necessarily a small BDP

CUBIC is designed to behave very similarly to AIMD TCP in the above
two types of networks. The following two tables show the average
window sizes of AIMD TCP, HSTCP, and CUBIC. The average window sizes
of AIMD TCP and HSTCP are from {{?RFC3649}}. The average window size
of CUBIC is calculated using {{eq6}} and the CUBIC AIMD-friendly
region for three different values of *C*.

| Loss Rate P | AIMD | HSTCP | CUBIC (C=0.04) | CUBIC (C=0.4) | CUBIC (C=4) |
| ---:| ---:| ---:| ---:| ---:| ---:|
| 1.0e-02 | 12 | 12 | 12 | 12 | 12 |
| 1.0e-03 | 38 | 38 | 38 | 38 | 59 |
| 1.0e-04 | 120 | 263 | 120 | 187 | 333 |
| 1.0e-05 | 379 | 1795 | 593 | 1054 | 1874 |
| 1.0e-06 | 1200 | 12280 | 3332 | 5926 | 10538 |
| 1.0e-07 | 3795 | 83981 | 18740 | 33325 | 59261 |
| 1.0e-08 | 12000 | 574356 | 105383 | 187400 | 333250 |
{: #tab1 title="AIMD TCP, HSTCP, and CUBIC with RTT = 0.1 seconds"}

{{tab1}} describes the response function of AIMD TCP, HSTCP, and CUBIC
in networks with *RTT* = 0.1 seconds. The average window size is in
MSS-sized segments.

| Loss Rate P | AIMD | HSTCP | CUBIC (C=0.04) | CUBIC (C=0.4) | CUBIC (C=4) |
| ---:| ---:| ---:| ---:| ---:| ---:|
| 1.0e-02 | 12 | 12 | 12 | 12 | 12 |
| 1.0e-03 | 38 | 38 | 38 | 38 | 38 |
| 1.0e-04 | 120 | 263 | 120 | 120 | 120 |
| 1.0e-05 | 379 | 1795 | 379 | 379 | 379 |
| 1.0e-06 | 1200 | 12280 | 1200 | 1200 | 1874 |
| 1.0e-07 | 3795 | 83981 | 3795 | 5926 | 10538 |
| 1.0e-08 | 12000 | 574356 | 18740 | 33325 | 59261 |
{: #tab2 title="AIMD TCP, HSTCP, and CUBIC with RTT = 0.01 seconds"}

{{tab2}} describes the response function of AIMD TCP, HSTCP, and CUBIC
in networks with *RTT* = 0.01 seconds. The average window size is in
MSS-sized segments.

Both tables show that CUBIC with any of these three *C* values is more
friendly to AIMD TCP than HSTCP, especially in networks with a short
*RTT* where AIMD TCP performs reasonably well. For example, in a
network with *RTT* = 0.01 seconds and p=10^-6, AIMD TCP has an average
window of 1200 packets. If the packet size is 1500 bytes, then AIMD
TCP can achieve an average rate of 1.44 Gbps. In this case, CUBIC with
*C*=0.04 or *C*=0.4 achieves exactly the same rate as AIMD TCP,
whereas HSTCP is about ten times more aggressive than AIMD TCP.

We can see that *C* determines the aggressiveness of CUBIC in
competing with other congestion control algorithms for bandwidth.
CUBIC is more friendly to AIMD TCP, if the value of *C* is lower.
However, we do not recommend setting *C* to a very low value like
0.04, since CUBIC with a low *C* cannot efficiently use the bandwidth
in fast and long-distance networks. Based on these observations and
extensive deployment experience, we find *C*=0.4 gives a good balance
between AIMD- friendliness and aggressiveness of window increase.
Therefore, *C* SHOULD be set to 0.4. With *C* set to 0.4, {{eq6}} is
reduced to:

~~~ math
AVG\_W_{cubic} = 1.054 * \frac{\sqrt[3]{RTT^4}}{\sqrt[3]{p^4}}
~~~
{: #eq7 artwork-align="center" }

{{eq7}} is then used in the next subsection to show the scalability of
CUBIC.

## Using Spare Capacity

CUBIC uses a more aggressive window increase function than AIMD TCP
for fast and long-distance networks.

The following table shows that to achieve the 10 Gbps rate, AIMD TCP
requires a packet loss rate of 2.0e-10, while CUBIC requires a packet
loss rate of 2.9e-8.

| Throughput (Mbps) | Average W | AIMD P   | HSTCP P | CUBIC P |
|------------------:|----------:|--------:|--------:|--------:|
|                 1 |       8.3 | 2.0e-2  | 2.0e-2  | 2.0e-2  |
|                10 |      83.3 | 2.0e-4  | 3.9e-4  | 2.9e-4  |
|               100 |     833.3 | 2.0e-6  | 2.5e-5  | 1.4e-5  |
|              1000 |    8333.3 | 2.0e-8  | 1.5e-6  | 6.3e-7  |
|             10000 |   83333.3 | 2.0e-10 | 1.0e-7  | 2.9e-8  |
{: #tab3 title="Required packet loss rate for AIMD TCP,
HSTCP, and CUBIC to achieve a certain throughput"}

{{tab3}} describes the required packet loss rate for AIMD TCP, HSTCP,
and CUBIC to achieve a certain throughput. We use 1500-byte packets
and an *RTT* of 0.1 seconds.

Our test results in {{HKLRX06}} indicate that CUBIC uses the spare
bandwidth left unused by existing AIMD TCP flows in the same
bottleneck link without taking away much bandwidth from the existing
flows.

## Difficult Environments

CUBIC is designed to remedy the poor performance of AIMD TCP in fast
and long-distance networks.

## Investigating a Range of Environments

There is decade-long deployment experience with CUBIC on the Internet.
CUBIC has also been extensively studied by using both NS-2 simulation
and testbed experiments, covering a wide range of network
environments. More information can be found in {{HKLRX06}}.

Same as AIMD TCP, CUBIC is a loss-based congestion control algorithm.
Because CUBIC is designed to be more aggressive (due to a faster
window increase function and bigger multiplicative decrease factor)
than AIMD TCP in fast and long-distance networks, it can fill large
drop-tail buffers more quickly than AIMD TCP and increases the risk of
a standing queue {{?RFC8511}}. In this case, proper queue sizing and
management {{!RFC7567}} could be used to reduce the packet queuing
delay.

## Protection against Congestion Collapse

With regard to the potential of causing congestion collapse, CUBIC
behaves like AIMD TCP, since CUBIC modifies only the window adjustment
algorithm of AIMD TCP. Thus, it does not modify the ACK clocking and
timeout behaviors of AIMD TCP.

## Fairness within the Alternative Congestion Control Algorithm

CUBIC ensures convergence of competing CUBIC flows with the same RTT
in the same bottleneck links to an equal throughput. When competing
flows have different RTT values, their throughput ratio is linearly
proportional to the inverse of their RTT ratios. This is true
independently of the level of statistical multiplexing on the link.

## Performance with Misbehaving Nodes and Outside Attackers

This is not considered in the current CUBIC design.

## Behavior for Application-Limited Flows

CUBIC does not increase its congestion window size if a flow is
currently limited by the application instead of the congestion window.
In case of long periods during which *cwnd* has not been updated due
to such an application limit, such as idle periods, *t* in {{eq1}}
MUST NOT include these periods; otherwise, W<sub>cubic</sub>(*t*)
might be very high after restarting from these periods.

## Responses to Sudden or Transient Events

If there is a sudden congestion, a routing change, or a mobility
event, CUBIC behaves the same as AIMD TCP.

## Incremental Deployment

CUBIC requires only changes to TCP senders, and it does not require
any changes at TCP receivers. That is, a CUBIC sender works correctly
with the AIMD TCP receivers. In addition, CUBIC does not require any
changes to routers and does not require any assistance from routers.

# Security Considerations

CUBIC makes no changes to the underlying security of TCP. More
information about TCP security concerns can be found in {{!RFC5681}}.

# IANA Considerations

This document does not require any IANA actions.

--- back

# Acknowledgments

Richard Scheffenegger and Alexander Zimmermann originally co-authored
{{?RFC8312}}.

<!-- Anyone else to acknowledge? -->

# Evolution of CUBIC

<!-- For future PRs, please include a bullet below that summarizes the change
     and link the issue number to the GitHub issue page. -->

## Since draft-ietf-tcpm-rfc8312bis-02

- Decription of packet loss rate *p*
  ([#65](https://github.com/NTAP/rfc8312bis/issues/65))

- Clarification of TCP Friendly Equation for ABC and Delayed ACK
  ([#66](https://github.com/NTAP/rfc8312bis/issues/66))

- add applicability to QUIC and SCTP
  ([#61](https://github.com/NTAP/rfc8312bis/issues/61))

- clarity on setting <!--{{{α}{}}}-->alpha*<sub>aimd</sub>* to 1
  ([#68](https://github.com/NTAP/rfc8312bis/issues/68))

- introduce <!--{{{α}{}}}-->alpha*<sub>cubic</sub>*
  ([#64](https://github.com/NTAP/rfc8312bis/issues/64))

- clarify *cwnd* growth in convex region
  ([#69](https://github.com/NTAP/rfc8312bis/issues/69))

- add guidance for using bytes and mention that segments count is decimal
  ([#67](https://github.com/NTAP/rfc8312bis/issues/67))

## Since draft-ietf-tcpm-rfc8312bis-01

- address Michael Scharf's editorial suggestions.
  ([#59](https://github.com/NTAP/rfc8312bis/issues/59))
- add "Note to the RFC Editor" about removing underscores

## Since draft-ietf-tcpm-rfc8312bis-00

- use updated xml2rfc with better text rendering of subscripts

## Since draft-eggert-tcpm-rfc8312bis-03

- fix spelling nits
- rename to draft-ietf
- define *W<sub>max</sub>* more clearly

## Since draft-eggert-tcpm-rfc8312bis-02

- add definition for segments_acked and <!--{{{α}{}}}-->alpha*<sub>aimd</sub>*.
  ([#47](https://github.com/NTAP/rfc8312bis/issues/47))

- fix a mistake in *W<sub>max</sub>* calculation in the fast convergence section.
  ([#51](https://github.com/NTAP/rfc8312bis/issues/51))

- clarity on setting *ssthresh* and *cwnd<sub>start</sub>* during
  multiplicative decrease.
  ([#53](https://github.com/NTAP/rfc8312bis/issues/53))

## Since draft-eggert-tcpm-rfc8312bis-01

- rename TCP-Friendly to AIMD-Friendly and rename Standard TCP to AIMD
  TCP to avoid confusion as CUBIC has been widely used on the Internet.
  ([#38](https://github.com/NTAP/rfc8312bis/issues/38))

- change introductory text to reflect the significant broader
  deployment of CUBIC on the Internet.
  ([#39](https://github.com/NTAP/rfc8312bis/issues/39))

- rephrase introduction to avoid referring to variables that have not
  been defined yet.

## Since draft-eggert-tcpm-rfc8312bis-00

- acknowledge former co-authors
  ([#15](https://github.com/NTAP/rfc8312bis/issues/15))

- prevent *cwnd* from becoming less than two
  ([#7](https://github.com/NTAP/rfc8312bis/issues/7))

- add list of variables and constants
  ([#5](https://github.com/NTAP/rfc8312bis/issues/5),
  [#6](https://github.com/NTAP/rfc8312bis/issues/6))

- update *K*'s definition and add bounds for CUBIC *target* *cwnd*
  {{SXEZ19}} ([#1](https://github.com/NTAP/rfc8312bis/issues/1),
  [#14](https://github.com/NTAP/rfc8312bis/issues/14))

- update *W<sub>est</sub>* to use AIMD approach
  ([#20](https://github.com/NTAP/rfc8312bis/issues/20))

<!-- xml2rfc currently doesn't allow the α Unicode symbol in bullet lists -->
- set <!--{{{α}{}}}-->alpha*<sub>aimd</sub>* to 1 once
  *W<sub>est</sub>* reaches *W<sub>max</sub>*
  ([#2](https://github.com/NTAP/rfc8312bis/issues/2))

- add Vidhi as co-author
  ([#17](https://github.com/NTAP/rfc8312bis/issues/17))

- note for Fast Recovery during *cwnd* decrease due to congestion
  event ([#11](https://github.com/NTAP/rfc8312bis/issues/11))

- add section for spurious congestion events
  ([#23](https://github.com/NTAP/rfc8312bis/issues/23))

- initialize *W<sub>est</sub>* after timeout and remove variable
  *W<sub>last_max</sub>*
  ([#28](https://github.com/NTAP/rfc8312bis/issues/28))

## Since RFC8312

- converted to Markdown and xml2rfc v3
- updated references (as part of the conversion)
- updated author information
- various formatting changes
- move to Standards Track

## Since the Original Paper

CUBIC has gone through a few changes since the initial release
{{HRX08}} of its algorithm and implementation. Below we highlight the
differences between its original paper and {{?RFC8312}}.

- The original paper {{HRX08}} includes the pseudocode of CUBIC
  implementation using Linux's pluggable congestion control framework,
  which excludes system-specific optimizations. The simplified
  pseudocode might be a good source to start with and understand CUBIC.

- {{HRX08}} also includes experimental results showing its performance
  and fairness.

<!-- xml2rfc currently doesn't allow the β Unicode symbol in bullet lists -->
- The definition of <!--{{{β}{}}}-->beta*<sub>cubic</sub>* constant
  was changed in {{?RFC8312}}. For example,
  <!--{{{β}{}}}-->beta*<sub>cubic</sub>* in the original paper was the
  window decrease constant while {{?RFC8312}} changed it to CUBIC
  multiplication decrease factor. With this change, the current
  congestion window size after a congestion event in {{?RFC8312}} was
  <!--{{{β}{}}}-->beta*<sub>cubic</sub>* \* *W<sub>max</sub>* while it was
  (1-<!--{{{β}{}}}-->beta*<sub>cubic</sub>*) \* *W<sub>max</sub>* in the
  original paper.

- Its pseudocode used *W<sub>last_max</sub>* while {{?RFC8312}} used
  *W<sub>max</sub>*.

- Its AIMD-friendly window was *W<sub>tcp</sub>* while {{?RFC8312}} used
  *W<sub>est</sub>*.
