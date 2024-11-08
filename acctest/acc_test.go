package acctest_test

import (
	"github.com/hashicorp/hcl/v2"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/hashicorp/hcl/v2/hclwrite"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var testFolders = []string{
	filepath.Join("azurerm", "v3_v4"),
	filepath.Join("azuread", "v2_v3"),
}

func Test_Transform(t *testing.T) {
	for _, testFolder := range testFolders {
		absTestFolder := filepath.Join("..", testFolder)
		absTfDir := filepath.Join(absTestFolder, "test-fitness")
		var err error
		absTestFolder, err = filepath.Abs(filepath.Clean(absTestFolder))
		require.NoError(t, err)
		absTfDir, err = filepath.Abs(filepath.Clean(absTfDir))
		require.NoError(t, err)
		transformCmd := exec.Command("mapotf", "transform", "--mptf-dir", absTestFolder, "--tf-dir", absTfDir)
		transformCmd.Dir = absTestFolder
		defer func() {
			resetCmd := exec.Command("mapotf", "reset", "--tf-dir", absTfDir)
			resetCmd.Dir = absTestFolder
			resetCmd.Stdout = os.Stdout
			resetCmd.Stderr = os.Stderr
			resetCmd.Stdin = os.Stdin
			_ = resetCmd.Run()
		}()
		transformCmd.Stdout = os.Stdout
		transformCmd.Stderr = os.Stderr
		transformCmd.Stdin = os.Stdin
		require.NoError(t, transformCmd.Run())
		avmFixCmd := exec.Command("avmfix", "-folder", absTfDir)
		require.NoError(t, avmFixCmd.Run())
		tfDirFiles, err := os.ReadDir(absTfDir)
		require.NoError(t, err)
		for _, f := range tfDirFiles {
			if f.IsDir() {
				continue
			}
			if !strings.HasSuffix(f.Name(), ".wanted.hcl") {
				continue
			}
			t.Run(filepath.Join(testFolder, f.Name()), func(t *testing.T) {
				expected, err := os.ReadFile(filepath.Clean(filepath.Join(absTfDir, f.Name())))
				require.NoError(t, err)
				actual, err := os.ReadFile(filepath.Clean(filepath.Join(absTfDir, strings.TrimSuffix(f.Name(), ".wanted.hcl")+".tf")))
				require.NoError(t, err)
				expected = []byte(strings.ReplaceAll(string(expected), "\r", ""))
				actual = []byte(strings.ReplaceAll(string(actual), "\r", ""))
				//assert.Equal(t, strings.ReplaceAll(string(expected), "\r", ""), strings.ReplaceAll(string(actual), "\r", ""))
				compareHCLBlocks(t, string(expected), string(actual))
			})
		}
	}
}

func compareHCLBlocks(t *testing.T, expectedHCL, actualHCL string) {
	expectedFile, diag := hclwrite.ParseConfig([]byte(expectedHCL), "", hcl.InitialPos)
	require.False(t, diag.HasErrors())

	actualFile, diag := hclwrite.ParseConfig([]byte(actualHCL), "", hcl.InitialPos)
	require.False(t, diag.HasErrors())

	expectedBlocks := expectedFile.Body().Blocks()
	actualBlocks := actualFile.Body().Blocks()

	assert.Equal(t, len(expectedBlocks), len(actualBlocks), "Number of blocks do not match")

	for _, expectedBlock := range expectedBlocks {
		found := false
		for _, actualBlock := range actualBlocks {
			if expectedBlock.Type() == actualBlock.Type() && compareLabels(expectedBlock.Labels(), actualBlock.Labels()) {
				assert.Equal(t, string(expectedBlock.BuildTokens(nil).Bytes()), string(actualBlock.BuildTokens(nil).Bytes()), "Block content does not match")
				found = true
				break
			}
		}
		assert.True(t, found, "Expected block not found in actual blocks")
	}
}

// compareLabels compares two slices of labels for equality.
func compareLabels(expectedLabels, actualLabels []string) bool {
	if len(expectedLabels) != len(actualLabels) {
		return false
	}
	for i, label := range expectedLabels {
		if label != actualLabels[i] {
			return false
		}
	}
	return true
}
