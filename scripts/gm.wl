(* ::Package:: *)

ClearAll["Global`*"];


X[t_]  := (1 - t)^3*X0 + 3*t*(1 - t)^2*X1 + 3*t^2*(1 - t)*X2 + t^3*X3;
Y[t_]  := (1 - t)^3*Y0 + 3*t*(1 - t)^2*Y1 + 3*t^2*(1 - t)*Y2 + t^3*Y3;
NX[t_] := (1 - t)^3*X[u] + 3*t*(1 - t)^2*NX1 + 3*t^2*(1 - t)*NX2 + t^3*X3;
NY[t_] := (1 - t)^3*Y[u] + 3*t*(1 - t)^2*NY1 + 3*t^2*(1 - t)*NY2 + t^3*Y3;
GN[z_] := (u = z;
  dsr = First @ Solve[{
      NX[0.3] == X[z + 0.3*(1 - z)],
      NY[0.3] == Y[z + 0.3*(1 - z)],
      NX[0.7] == X[z + 0.7*(1 - z)],
      NY[0.7] == Y[z + 0.7*(1 - z)]},
    {NX1, NY1, NX2, NY2}];
  {{X[u], Y[u]}, {NX1, NY1} /. dsr, {NX2, NY2} /. dsr, {X[1], Y[1]}});
GS[$L1_, $L2_] := t /. FindRoot[
  (Y[t] - $L2[[2]])*($L1[[1]] - $L2[[1]]) == (X[t] - $L2[[1]])*($L1[[2]] - $L2[[2]]), {t, 0}];
AG[\[Theta]_] := 0.25*Pi*(1 + Erf[10*(\[Theta] - Pi/4)]);
AAG[\[Theta]_] := Piecewise[{
  {AG[\[Theta] + Pi] + Pi/2, Inequality[-Pi, LessEqual, \[Theta], Less, -Pi/2]},
  {AG[\[Theta] + Pi/2], Inequality[-Pi/2, LessEqual, \[Theta], Less, 0]},
  {AG[\[Theta]] + Pi/2, Inequality[0, LessEqual, \[Theta], Less, Pi/2]},
  {AG[\[Theta] - Pi/2], True}}];
TRR1[{{x1_, y1_}, {x2_, y2_}}, $vv1_, $vv2_] :=
  Module[
    {
      $v1, $v2, $v,
      $x, $y, $l, $ctr,
      $P1, $P2, $P3,
      $V12, $l1, $l2, $lt,
      MP1, MP2, $1P1, $1P2, $2P1, $2P2
    },
    $v1 = Normalize[$vv1];
    $v2 = Normalize[$vv2];
    $v  = Normalize[$v1 + $v2];
    {$x, $y} = 0.5*({x1, y1} + {x2, y2});
    $l   = Norm[{x1, y1} - {x2, y2}];
    $ctr = {$x, $y} + 0.1*$l*$v;
    $V12 = AAG[ArcTan[$v[[1]], $v[[2]]]]; $V12 = {Cos[$V12], Sin[$V12]};
    $P1 = {x$, y$} /. First @ NSolve[
      {(y$ - y1)*$v1[[1]] == (x$ - x1)*$v1[[2]], (y$ - $ctr[[2]])*$V12[[1]] == (x$ - $ctr[[1]])*$V12[[2]]},
      {x$, y$}];
    $P2 = {x$, y$} /. First @ NSolve[
      {(y$ - y2)*$v2[[1]] == (x$ - x2)*$v2[[2]], (y$ - $ctr[[2]])*$V12[[1]] == (x$ - $ctr[[1]])*$V12[[2]]},
      {x$, y$}];
    $V12 = $P2 - $P1;
    $P3 = Normalize[$V12] . $v;
    If[$P3 > 0.1, $P3 = $ctr + 0.25*$V12, $P3 = $ctr - 0.25*$V12];
    $l   = Norm[$V12];
    $V12 = Normalize[$V12];
    $l1  = Norm[$P1 - $P3];
    $l2  = Norm[$P2 - $P3];
    $lt  = If[2*$l1 > $l, 0.8, 1.25];
    MP1  = $P1 - $v1*$l1*$lt;
    MP2  = $P2 - ($v2*$l2)/$lt;
    $1P1 = MP1 + 0.5*($v1*$l1*$lt)*If[$lt > 1, 1., 1.3];
    $2P1 = $P3 - 0.5*$V12*$l1;
    $1P2 = MP2 + (($v2*$l2)*If[$lt < 1, 1., 1.3]) / (2*$lt);
    $2P2 = $P3 + 0.5*$V12*$l2;
    N[{MP1, $1P1, $2P1, $P3, $2P2, $1P2, MP2}]
  ];


Crs[$vc1_, $vc2_] :=
  Module[{$nvc1, $nvc2},
    $nvc1 = Normalize[$vc1];
    $nvc2 = Normalize[$vc2];
    $nvc1[[1]]*$nvc2[[2]] - $nvc1[[2]]*$nvc2[[1]]
  ];


Opr[$n_, $gcrs_] :=
  Module[{$w, prv, nxt},
    $w = StringReplace[s[[$n]], {" " -> ","}];
    $w = ToExpression[StringJoin["{{",
      StringReplace[$w, {"\n" -> "},\n{",
        "0x" -> "OX",
        "1x" -> "OX",
        "2x" -> "OX",
        "3x" -> "OX",
        "4x" -> "OX"}],
      "}}"]
    ];
    tl[[$n]] = (Take[#1, -2] & ) /@ $w;
    tl[[$n]] = Array[{tl[[$n,#1,1]],
      Interpreter["HexInteger"][StringReplace[ToString[tl[[$n,#1,2]]], "OX" -> ""]]} & ,
      Length[tl[[$n]]]];
    $w = (Drop[#1, -2] & ) /@ $w;
    $w = (ArrayReshape[#1, {Length[#1]/2, 2}] & ) /@ $w;
    $w = Array[Join[{Last[$w[[#1]]]}, $w[[#1 + 1]]] & , Length[$w] - 1];
    ow[[$n]] = $w;
    nln = Length[$w];
    For[$id = nln + 1, $id > 1, $id--;
      If[Length[$w[[$id]]] == 2 && Norm[$w[[$id,1]] - $w[[$id,2]]] < 69,
          prv = If[$id > 1, $id - 1, -1];
          nxt = If[$id == nln, 1, $id + 1];
          If[Norm[$w[[$id,1]] - $w[[$id,2]]] < 17 + 53 * Boole[
                       $gcrs * Crs[$w[[$id,1]] - $w[[prv,-2]], $w[[$id,2]] - $w[[$id,1]]] > 0.1
                    && $gcrs*Crs[$w[[$id,2]] - $w[[$id,1]], $w[[nxt,2]] - $w[[$id,2]]] > 0.1]
                && Abs[Crs[$w[[$id,1]] - $w[[prv,-2]], $w[[$id,2]] - $w[[nxt,2]]]] < 0.98,
            cgrst = TRR1[$w[[$id]], $w[[$id,1]] - $w[[prv,-2]], $w[[$id,2]] - $w[[nxt,2]]];
            If[Length[$w[[prv]]] == 4,
              {X0, Y0}     = $w[[prv,-1]];
              {X1, Y1}     = $w[[prv,-2]];
              {X2, Y2}     = $w[[prv,-3]];
              {X3, Y3}     = $w[[prv,-4]];
              $w[[prv]]    = Reverse[GN[GS[cgrst[[1]], cgrst[[4]]]]];
              cgrst[[2]]   = $w[[prv,-1]]
                + Norm[cgrst[[2]] - cgrst[[1]]] * Normalize[$w[[prv,-1]] - $w[[prv,-2]]];
              cgrst[[1]]   = $w[[prv,-1]]; ,
              $w[[prv,-1]] = cgrst[[1]];
            ];
            If[Length[$w[[nxt]]] == 4,
              {X0, Y0}    = $w[[nxt,1]];
              {X1, Y1}    = $w[[nxt,2]];
              {X2, Y2}    = $w[[nxt,3]];
              {X3, Y3}    = $w[[nxt,4]];
              $w[[nxt]]   = GN[GS[cgrst[[7]], cgrst[[4]]]];
              cgrst[[-2]] = $w[[nxt,1]]
                + Norm[cgrst[[-1]] - cgrst[[-2]]]*Normalize[$w[[nxt,1]] - $w[[nxt,2]]];
              cgrst[[-1]] = $w[[nxt,1]]; ,
              $w[[nxt,1]] = cgrst[[-1]];
            ];
            $w = Insert[$w, Take[cgrst, -4], $id + 1];
            $w[[$id]] = Take[cgrst, 4];
            tl[[$n, If[$id == 1, -1, $id]]] =
              {tl[[$n, If[$id == 1, -1, $id],1]], If[Length[$w[[prv]]] == 2, 2, 0]};
            tl[[$n,$id + 1]] = {"c", 0};
            tl[[$n]] = Insert[tl[[$n]], {"c", If[Length[$w[[nxt]]] == 2, 2, 0]}, $id + 2];
          ]
      ]
    ];
    cw[[$n]] = $w;
  ];


TRR2[ptv1_, ptv2_, lth_] := Module[{$v1, $v2},
  $v1 = Normalize[ptv1];
  $v2 = Normalize[ptv2];
  N[{lth*$v1, (lth*$v1)/3, (lth*$v2)/3, lth*$v2}]];


Oprs[$n_, $gcrs_] :=
  Module[{$w, prv, temp},
    $w = cw[[$n]];
    nln = Length[$w];
    For[$id = nln + 1, $id > 1,
      $id--;
      prv = If[$id > 1, $id - 1, -1];
      temp = Crs[$w[[$id,1]] - $w[[prv,-2]], $w[[$id,2]] - $w[[$id,1]]];
      If[$gcrs*temp > 0.1 || $gcrs*temp < -0.1,
        If[$gcrs*temp > 0.1, temp = 30, temp = 10];
        cgrst = TRR2[$w[[prv,-2]] - $w[[$id,1]], $w[[$id,2]] - $w[[$id,1]], temp]
          /. {x_, y_} -> {x, y} + $w[[$id,1]];
        If[Length[$w[[prv]]] == 4,
          {X0, Y0}  = $w[[prv,-1]];
          {X1, Y1}  = $w[[prv,-2]];
          {X2, Y2}  = $w[[prv,-3]];
          {X3, Y3}  = $w[[prv,-4]];
          $w[[prv]] = Reverse[GN[t /.
            FindMinimum[{(X[t] - cgrst[[1,1]])^2 + (Y[t] - cgrst[[1,2]])^2, 0 < t < 1}, {t, 0.1}][[2]]
          ] ];
          cgrst[[2]] = $w[[prv,-1]]
            + Norm[cgrst[[2]] - cgrst[[1]]] * Normalize[$w[[prv,-1]] - $w[[prv,-2]]];
          cgrst[[1]] = $w[[prv,-1]]; ,
          $w[[prv,-1]] = cgrst[[1]];
        ];
        If[Length[$w[[$id]]] == 4,
          {X0, Y0} = $w[[$id,1]];
          {X1, Y1} = $w[[$id,2]];
          {X2, Y2} = $w[[$id,3]];
          {X3, Y3} = $w[[$id,4]];
          $w[[$id]] = GN[t /.
            FindMinimum[{(X[t] - cgrst[[-1,1]])^2 + (Y[t] - cgrst[[-1,2]])^2, 0 < t < 1}, {t, 0.1}][[2]
          ] ];
          cgrst[[-2]] = $w[[$id,1]]
            + Norm[cgrst[[-2]] - cgrst[[-1]]]*Normalize[$w[[$id,1]] - $w[[$id,2]]];
          cgrst[[-1]] = $w[[$id,1]]; ,
          $w[[$id,1]] = cgrst[[-1]];
        ];
        $w = Insert[$w, cgrst, $id];
        tl[[$n,If[$id == 1, -1, $id]]] =
          {tl[[$n,If[$id == 1, -1, $id],1]], If[Length[$w[[prv]]] == 2, 2, 0]};
        tl[[$n]] = Insert[tl[[$n]], {"c", If[Length[$w[[$id]]] == 2, 2, 0]}, $id + 1];
      ]
    ];
    cw[[$n]] = $w;
  ];


Jn[x_, bs_] := Module[{$xx},
  $xx = (StringJoin[" ", #1] & ) /@ x;
  If[bs, $xx[[1]] = x[[1]]];
  StringJoin[StringJoin[$xx], "\n"]];


Tstr[$n_] := Module[{$w},
  $w = cw[[$n]];
  $w = Join[{{$w[[1]][[1]]}}, (Drop[#1, 1] & ) /@ $w];
  $w = Array[Join[Flatten[$w[[#1]]], tl[[$n]][[#1]]] & , Length[$w]];
  $w = Array[ToString /@ $w[[#1]] & , Length[$w]];
  StringJoin[Array[Jn[$w[[#1]], #1 == 1] & , Length[$w]]]];


SetDirectory[NotebookDirectory[]];


CG[fname_] := (
    str = Import[fname, "Text"];
    s = StringCases[str, "SplineSet\n"~~splineSet__~~"\nEndSplineSet" -> splineSet][[1]];
    s = StringReplace[s, "\n " -> "#"];
    s = StringSplit[s, "\n"];
    s = (StringReplace[#1, "#" -> "\n"] & ) /@ s;
    ow = cw = tl = Range[Length[s]];
    (Opr[#1, -1] &  ) /@ Range[Length[s]];
    (Oprs[#1, -1] & ) /@ Range[Length[s]];
    OW = Flatten[ow, 1];
    CW = Flatten[cw, 1];
    ((tl[[#1,1,2]] = tl[[#1,-1,2]]) & ) /@ Range[Length[s]];
    cw = Round[cw, 0.00001];
    str = StringJoin[StringCases[str, __~~"\nSplineSet\n"],
      StringJoin[Tstr /@ Range[Length[cw]]], StringCases[str, "EndSplineSet"~~__]];
  );


fns = Flatten[StringCases[FileNames[], __~~".glyph"]];
Length[fns]
CG[fns[[1]]];
Graphics[{
  Array[BezierCurve[OW[[#1]]] & , Length[OW]],
  Blue, Array[BezierCurve[CW[[#1]]] & , Length[CW]]}]


Oprz[$n_, rto_] :=
  Module[{$w, prv, nxt, temp},
    $w = StringReplace[s[[$n]], {" " -> ","}];
    $w = ToExpression[
      StringJoin["{{",
        StringReplace[$w,
          {
            "\n" -> "},\n{",
            "0x" -> "OX",
            "1x" -> "OX",
            "2x" -> "OX",
            "3x" -> "OX",
            "4x" -> "OX"
          }
        ], "}}"]];
    tl[[$n]] = (Take[#1, -2] & ) /@ $w;
    tl[[$n]] = Array[{tl[[$n,#1,1]],
        Interpreter["HexInteger"][StringReplace[ToString[tl[[$n,#1,2]]], "OX" -> ""]]} &,
      Length[tl[[$n]] ] ];
    $w = (Drop[#1, -2] & ) /@ $w;
    $w = (ArrayReshape[#1, {Length[#1]/2, 2}] & ) /@ $w;
    $w = Array[Join[{Last[$w[[#1]]]}, $w[[#1 + 1]]] & , Length[$w] - 1];
    ow[[$n]] = $w;
    $w += SFT*rto;
    cw[[$n]] = $w
  ];


CGG[fname_, rto_] := (
    str = Import[fname, "Text"];
    s = StringCases[str, "SplineSet\n"~~splineSet__~~"\nEndSplineSet" -> splineSet][[1]];
    s = StringReplace[s, "\n " -> "#"];
    s = StringSplit[s, "\n"];
    s = (StringReplace[#1, "#" -> "\n"] & ) /@ s;
    ow = cw = tl = Range[Length[s]];
    (Oprz[#1, rto] & ) /@ Range[Length[s]];
    OW = Flatten[ow, 1];
    CW = Flatten[cw, 1]; ((tl[[#1,1,2]] = tl[[#1,-1,2]]) & ) /@ Range[Length[s]];
    cw = Round[cw, 0.00001];
    str = StringJoin[StringCases[str, __~~"\nSplineSet\n"],
      StringJoin[Tstr /@ Range[Length[cw]]],
      StringCases[str, "EndSplineSet"~~__]
    ];
    Export[fname, str, "Text"];
  );


fns = Flatten[StringCases[FileNames[], __~~".glyph"]];
lth = Length[fns]
(CGG[fns[[#1]], #1/lth] & ) /@ Range[lth];
Graphics[{
    Array[BezierCurve[OW[[#1]]] & , Length[OW]],
    Blue,
    Array[BezierCurve[CW[[#1]]] & , Length[CW]]
  }]


SFT = N @
  {
    { {200, -2500}, {200, -2500}, {200, -2500}, {200, -2500} },
    { {200, -2500}, {200 - 50*Sqrt[2], -2500 + 50*Sqrt[2]}, {0, -1500}, {0, 0} },
    { {0, 0}, {0, 1500}, {200 - 50*Sqrt[2], 2500 - 50*Sqrt[2]}, {200, 2500} },
    { {200, 2500}, {200, 2500}, {200, 2500}, {200, 2500} },
    { {200, 2500}, {200, 2500}, {200, 2500}, {200, 2500} },
    { {200, 2500}, {200, 2500}, {200, 2500}, {200, 2500} },
    { {200, 2500}, {200 - 50*Sqrt[2], 2500 - 50*Sqrt[2]}, {0, 1500}, {0, 0} },
    { {0, 0}, {0, -1500}, {200 - 50*Sqrt[2], -2500 + 50*Sqrt[2]}, {200, -2500} },
    { {200, -2500}, {200, -2500}, {200, -2500}, {200, -2500} },
    { {200, -2500}, {200, -2500}, {200, -2500}, {200, -2500} }
  };
