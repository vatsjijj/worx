module words;

const DROP2 = "2drop : drop drop ;";
const SWAP =
  "swap : []ivswap ! >r []ivswap @ r> []ivswap del ;";
const NIP = "nip : swap drop ;";
const DUP =
  "dup : []ivdup ! []ivdup @ []ivdup @ []ivdup del ;";
const ROT = "rot : >r swap r> swap ;";
const OVER = "over : >r dup r> swap ;";
const DUP2 = "2dup : over over ;";
const TOR2 = "2>r : >r >r ;";
const RFROM2 = "2r> : r> r> ;";
const RFETCH = "r@ : r> dup >r ;";

const FULL = DROP2 ~ "\n" ~
             SWAP ~ "\n" ~
             NIP ~ "\n" ~
             DUP ~ "\n" ~
             ROT ~ "\n" ~
             OVER ~ "\n" ~
             DUP2 ~ "\n" ~
             TOR2 ~ "\n" ~
             RFROM2 ~ "\n" ~
             RFETCH ~ "\n\n";