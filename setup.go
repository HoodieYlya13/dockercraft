package main

import (
	"os/exec"

	log "github.com/sirupsen/logrus"
)

const (
	// We no longer download docker binary at runtime.
	// We expect it to be present in the container.
	dockerBinary = "docker"
)

// GetDockerBinary ensures that we have the right version docker client
// for communicating with the Docker Daemon
func (d *Daemon) GetDockerBinary() error {
	// We simply rely on the system "docker" command which is installed in the Dockerfile.
	d.BinaryName = dockerBinary
	log.Infof("Using system docker binary: %s", d.BinaryName)

	path, err := exec.LookPath(d.BinaryName)
	if err != nil {
		log.Warnf("Docker binary %q not found in PATH. This may cause issues. Error: %v", d.BinaryName, err)
		return err
	}
	log.Infof("Found docker binary at: %s", path)

	return nil
}
