import argparse
from Bio import SeqIO
from Bio.SeqIO import FastaIO

#usage: python filterNFasta.py --inputFasta test.fa --outputFasta test3.fa --threshold 0.01
#frequency default as 0.05

def parseArgument():
        # Parse the input
        parser=argparse.ArgumentParser(description=\
                        "Filter sequences with N% > 5%")
        parser.add_argument("--inputFasta", required=True)
        parser.add_argument("--outputFasta", required=True, help='Filtered Fasta file')
        parser.add_argument("--threshold", nargs='?', const=0.05, default=0.05)
        args = parser.parse_args()
        return args

def filterSequence(args):
	#Filter out sequences with N% > the threshold
    outputFile = open(args.outputFasta, 'w+')
    fastaOut = FastaIO.FastaWriter(outputFile, wrap=None)
    count = 0
    recordList = []
    for record in SeqIO.parse(args.inputFasta, "fasta"):
        seq = record.seq
        n_freq = (seq.count('n') + seq.count('N'))/len(seq)
        if n_freq > float(args.threshold):
            count+=1
            continue
        else:
            recordList.append(record)
    fastaOut.write_file(recordList)
    print(args.inputFasta, "filtered out", count)

if __name__ == "__main__":
        args = parseArgument()
        filterSequence(args)