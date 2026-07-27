---
# Knowledge Frontmatter (required)
id: tcp-reliability
title: TCP Reliability Guarantees
category: concept
mastery_level: L4
source: "RFC 9293 (Transmission Control Protocol)"
verified: true
authored_by: learner
updated: 2026-07-28
related_skills: [socratic-hint-ladder]
provenance: dialogue/tcp-reliability.md
---

# TCP Reliability Guarantees

## 1. Claim (Verified Fact)
TCP provides **reliable, in-order** delivery of a byte stream: every byte is delivered exactly once and
in the order sent, achieved through sequence numbers, cumulative acknowledgements, and retransmission of
un-acknowledged segments.

## 2. Why It's True (Grounding)
Each segment carries a sequence number; the receiver acknowledges the highest contiguous byte received.
A sender that does not receive an ACK within its retransmission timeout resends the segment. Ordering is
reconstructed at the receiver from sequence numbers, so out-of-order arrivals are buffered until the gap
is filled. (Per RFC 9293.)

## 3. Boundary Conditions
- **Holds when:** the connection is established and both endpoints follow the protocol.
- **Breaks when:** the connection resets (RST) or is torn down — undelivered data is lost; TCP guarantees
  ordering *within* a connection, not across reconnects.

## 4. Connections (Relational)
- Relates to: `ordered-delivery` — ordering REQUIRES retransmission, because a missing early segment
  stalls delivery of later ones until it is resent.
- Relates to: `reliability-vs-latency` — the same guarantee that ensures order can HURT latency on lossy,
  high-RTT links (head-of-line blocking).

## 5. Transfer (L4 Marker)
> Reliability-vs-latency is a general trade-off: like RAID mirroring buys durability with write speed,
> TCP buys ordered reliability with potential latency. The *same tension* recurs across systems.

## 6. Provenance
- **Reached via:** Gate 3 (Articulate) on 2026-07-28
- **Verified at:** Gate 2 by human
- **Dialogue:** dialogue/tcp-reliability.md
- **Original learner articulation:** "Ordering needs every segment, so a lost one must be resent before
  later ones can be used — that's why order and retransmission are the same guarantee."
