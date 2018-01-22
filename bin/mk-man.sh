#!/bin/bash
DOC="$1"
ronn --roff doc/${DOC}.1.ronn && mv doc/${DOC}.1 man/man1/
