package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/bitrise-io/codesigndoc/osxkeychain"
	"github.com/bitrise-io/go-utils/log"
)

func main() {
	exportCert(os.Args[1])
}

func exportCert(certificateCN string) {
	identitiesWithKeychainRefs := []osxkeychain.IdentityWithRefModel{}
	defer osxkeychain.ReleaseIdentityWithRefList(identitiesWithKeychainRefs)

	log.Printf("searching for Identity: %s", certificateCN)
	identityRef, err := osxkeychain.FindAndValidateIdentity(certificateCN)
	if err != nil {
		fmt.Errorf("failed to export, error: %s", err)
	}

	if identityRef == nil {
		fmt.Errorf("identity not found in the keychain, or it was invalid (expired)")
	}

	identitiesWithKeychainRefs = append(identitiesWithKeychainRefs, *identityRef)

	identityKechainRefs := osxkeychain.CreateEmptyCFTypeRefSlice()
	for _, aIdentityWithRefItm := range identitiesWithKeychainRefs {
		fmt.Println("exporting Identity:", aIdentityWithRefItm.Label)
		identityKechainRefs = append(identityKechainRefs, aIdentityWithRefItm.KeychainRef)
	}

	fmt.Println()
	log.Warnf("Exporting from Keychain...")
	fmt.Println()

	identities, err := osxkeychain.ExportFromKeychain(identityKechainRefs, false)
	if err != nil {
		fmt.Errorf("failed to export from Keychain: %s", err)
	}

	currentDir, _ := os.Getwd()
	ioutil.WriteFile(filepath.Join(fmt.Sprintf("%s/certs", currentDir), fmt.Sprintf("exported_%s.p12", certificateCN)), identities, 0600)
}
