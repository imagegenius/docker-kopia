package main

import (
	"testing"

	helpers "github.com/hydazz/containers/tests"
)

func Test(t *testing.T) {
	image := helpers.GetTestImage("kopia:local")
	t.Logf("testing image: %s", image)

	helpers.RequireCommandSucceeds(t, image, nil, "/usr/local/bin/kopia", "--version")
}
