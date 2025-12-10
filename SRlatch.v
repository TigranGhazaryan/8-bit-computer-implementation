module  SRlatch (S, R, Q, Q_bar);
    input S, R;
    output Q, Q_bar;

    nor n1(Q, R, Q_bar);
    nor n2(Q_bar, S, Q);
    
endmodule