package main

import (
	"context"
	"testing"

	"github.com/imagegenius/docker-kopia/tests/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("kopia:local")
	t.Logf("testing image: %s", image)

	testhelpers.TestCommandSucceeds(t, ctx, image, nil, "/usr/local/bin/kopia", "--version")
}
