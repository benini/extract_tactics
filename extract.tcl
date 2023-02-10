# Extract tactical positions from a database.
# Usage:
#   scid.exe extract.tcl engine.exe input_database.pgn
# A file tactics.pgn will be created with a line for each position. For example:
# [FEN "the fen position"] {last_move_in_uci_format}

# Engine configuration
set engine_options {}
lappend engine_options [list MultiPV 2]
lappend engine_options [list Threads 4]
lappend engine_options [list Hash 1024]
set engine_limits {}
lappend engine_limits [list depth 30]
lappend engine_limits [list movetime 2000]

# Create the output file
set out_file [open "tacticts.pgn" w]

# This procedure will be invoked for every position in input_database
proc analyzed_position {fen last_move} {
    # The last evaluations received from the engine are stored in a global array
    global enginePVs

    # Ignore position with only one valid move
    if {![info exists enginePVs(2)]} { return }

    # Ignore position where there are multiple good moves
    lassign $enginePVs(2) score2 score_type2
    if {$score_type2 eq "mate" || $score2 > 900} { return }

    # Ignore position where the best move is not good enough
    lassign $enginePVs(1) score1 score_type1 pv1
    if {$score_type1 ne "mate" && $score1 < 2000} { return }

    # Output the position
    puts $::out_file "\[FEN \"$fen\"\] {last_move: $last_move} $pv1"
    flush $::out_file
}

# Parse input args
lassign $argv engine_exe input_database
set engine_exe [file nativename $engine_exe]
set input_database [file nativename $input_database]
if {$engine_exe eq "" || $input_database eq ""} {
    error "Usage: scid extract.tcl engine.exe input_database"
}

# Load the engine module from scid
set scidDir [file nativename [file dirname [info nameofexecutable]]]
source -encoding utf-8 [file nativename [file join $::scidDir "tcl" "enginecomm.tcl"]]

# Callbacks from the engines
# Store the latest PV into the global array ::enginePV(PV)
proc engine_messages {msg} {
    lassign $msg msgType msgData
    if {$msgType eq "InfoPV"} {
        lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
        set ::enginePVs($multipv) [list $score $score_type $pv]
    }
}
proc engine_log {msg} {
    if {[string match "bestmove *" $msg]} {
        set ::engine_done 1
    }
}

# Open the engine
::engine::setLogCmd engine1 engine_log
::engine::connect engine1 engine_messages $engine_exe {}
::engine::send engine1 SetOptions $engine_options

# Open the database
set codec SCID5
if {[string equal -nocase ".pgn" [file extension $input_database]]} {
    set codec PGN
}
set base [sc_base open $codec $input_database]

# Iterate every position
set nGames [sc_base numGames $base]
for {set i 1} {$i <= $nGames} {incr i} {
    ::engine::send engine1 NewGame [list analysis post_pv post_wdl]
    sc_game load $i
    while 1 {
        unset -nocomplain ::enginePVs
        set ::enginePVs(1) {}
        ::engine::send engine1 Go [list [sc_game UCI_currentPos] $engine_limits]
        vwait ::engine_done
        analyzed_position [sc_pos fen] [sc_game info previousMoveUCI]
        if {[sc_pos isAt end]} break
        sc_move forward
    }
}

# Clean up
close $out_file
::engine::close engine1
sc_base close $base

