# ═══════════════════════════════════════
# Domain — Enums: Grade Symbol
# ═══════════════════════════════════════
from enum import Enum


class GradeSymbol(str, Enum):
    A_PLUS = "A+"
    A = "A"
    A_MINUS = "A-"
    B_PLUS = "B+"
    B = "B"
    B_MINUS = "B-"
    C_PLUS = "C+"
    C = "C"
    C_MINUS = "C-"
    D_PLUS = "D+"
    D = "D"
    D_MINUS = "D-"
    F = "F"
    # Special symbols
    IC = "Ic"    # Incomplete
    W = "W"      # Withdrawn
    AU = "AU"    # Audit
    S = "S"      # Satisfactory
    TC = "TC"    # Transfer Credit
    EX = "EX"    # Exempt
