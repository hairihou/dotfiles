---
name: writing-ja
description: Revise Japanese internal technical writing — planning docs, design proposals, meeting material aimed at developers — so it reads accurate and plain: deflate overstatement, drop insider jargon and hollow phrasing, tighten repetition. Use when drafting or revising such prose. Not for English, reference, or CLI text.
allowed-tools: Read, Write
---

# Japanese Writing

技術文書（方針・計画、設計提案、会議資料）を、読み手の開発者が正確に、素直に読める形へ直す。誇張を削り、内輪の言葉を読者の言葉に置き換え、ぼやけた箇所を具体化し、繰り返しを詰める。

## Don't Overstate

事実より強く書かない。確定していないことを、確定したように書かない。

- 最上級・比較・誇張を、検証できる事実まで下げる。
- 未確定の時期や数値を決め打ちで書かない。確定した分だけ書く。
- 推量や見込みを、根拠なく断定へ変えない。本文の根拠で確定しているときだけ言い切る。
- 検出・保証・解決を「必ずできる」と書かない。条件を添える（「〜しやすい」「〜が成り立つときに限る」）。

## Use the Reader's Words

読者がそのまま受け取れる語を使う。書き手にしか通じない省略と、気取った語を外す。

- 内輪の略号は、読者に通じる言葉へ展開する。
  - 「M6目標／M1のベースライン測定後」→「6ヶ月時点目標／1ヶ月目のベースライン測定後」
- 技術用語は素直に英語で書く。漢語訳やカタカナに寄せない。
  - 契約 → Promise、バンドラー → Bundler
- 気取った語や比喩を、ふつうの語に置き換える。
  - 踏み込んで → 取り組む、Go/No-go判断 → 判定

## Tight and Concrete

一文ずつ、置く理由があるか確かめる。理由がなければ削り、ぼやけていれば具体にする。

- 同じ主張を言い換えて繰り返さない。冗長な説明は、枠組みだけ残して一塊に圧縮する。
- 場面や経緯を書いた直後に、それを要約し直さない。
- 後で参照しない固有名や、装飾的な精度（時刻、細かい数値）は削る。
- 抽象的な言い方は、丸括弧の同格挿入でその場で何を指すか定める。読者に前を読み返させない。
- 抽象的な施策や主張には、具体例を一つ以上添えて像を結ばせる。

## Headings

見出しは、その節の中身が分かる素直な句にする。

- 気取った言い回しをやめ、中身を指す自然な語にする。
- 一つの見出しに二要素（種別と主題など）を詰め込まない。
- 結論を言い切る「セリフ」にしない。見出しでオチを見せない。

## No Filler

中身を足さず、書けているように見せるだけの言い回しを外す。

- 「重要なのは〜だ」「〜に他ならない」のような、主張を予告するだけの前置きを置かない。主張を直接書く。
- 短い決め台詞を独立させて緊張を作る書き方を、繰り返し使わない。
- 「AではなくBだ」という対句を多用しない。

## Process

1. Don't Overstate → Use the Reader's Words → Tight and Concrete → Headings → No Filler の順に、直す箇所を拾う。
2. 元の意味と構成（見出し、コードブロック、図表）を保ったまま、本文だけ書き換える。
3. 対象がファイルなら Write で上書きし、直した箇所を報告する。チャットに貼られたテキストが対象なら、推敲結果をそのまま出す。
