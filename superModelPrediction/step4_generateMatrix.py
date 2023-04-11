import argparse
import pandas as pd
import os
import numpy as np

# parse Npy predictions into list
def parseNpy(input):
    inputNpy=np.load(input)
    prob=[]
    for i in inputNpy:
        prob.append(i[1]) # use probability of class1
    res=[]
    for i in range(0, len(prob), 2):
        if np.abs(prob[i]-prob[i+1]) > 0.5 : # discard gaps > 0.5
            res.append(-1)
        else:
            res.append((prob[i]+prob[i+1])/2) # take average of forward+reverse
    return res

# merge gene Name with prediction value
def getOneSpecies(npyFile, species, nameDir):
    geneName=str(nameDir+"/"+species+".txt")
    geneList=[]
    with open(geneName) as f:
        geneList = f.read().splitlines()
    f.close()

    npy=parseNpy(npyFile)
    if len(npy) != len(geneList):
        raise Exception("Gene List doesn't match prediction for:", species)
    prediction={}
    for i, val in enumerate(geneList):
        prediction[val] = npy[i]
    return prediction

def main(args):
    
    #initialize matrix with rat,bat,macaque
    df = pd.DataFrame()
    for files in os.listdir(args.npyDir):
        if files.endswith(".npy"):
            tmpName=files.split(".")[0].split("_")
            species=tmpName[0]+'_'+tmpName[1]
            if species == "Macaca_mulatta" or species == "Rattus_norvegicus" or species == "Rousettus_aegyptiacus":
                prediction=getOneSpecies(args.npyDir+"/"+files, species, args.nameDir)
                tmpDf=pd.DataFrame(prediction.items(), columns=['name', species])
                df = pd.concat([df, tmpDf])

    #add other species
    for files in os.listdir(args.npyDir):
        if files.endswith(".npy"):
            tmpName=files.split(".")[0].split("_")
            species='_'.join(tmpName[:len(tmpName)-1])
            print('handling', species)
            if species == "Macaca_mulatta" or species == "Rattus_norvegicus" or species == "Rousettus_aegyptiacus":
                continue
            prediction=getOneSpecies(args.npyDir+"/"+files, species, args.nameDir)
            tmpDf=pd.DataFrame(prediction.items(), columns=['name', species])
            df = pd.merge(df, tmpDf, how='left')
    
    df = df.fillna(-1)
    df = df.sort_values(by='Name')    
    print('generating csv')           
    df.to_csv(args.output, sep = '\t', index = False)

if __name__ == '__main__':  
    parser = argparse.ArgumentParser()
    parser.add_argument("--npyDir", type=str, help="input npy files directory")
    parser.add_argument("--nameDir", type=str, help="input fasta files directory")
    parser.add_argument("--output", type=str)
    args = parser.parse_args()
    main(args)
