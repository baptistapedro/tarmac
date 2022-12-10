package main

import (
	"os"
	"context"
	"github.com/madflojo/tarmac/pkg/wasm"
)

type ModuleCase struct {
	ModuleConf wasm.ModuleConfig
	Pass       bool
	Name       string
}


func main() {
	s, err := wasm.NewServer(wasm.Config{
		Callback: func(context.Context, string, string, string, []byte) ([]byte, error) { return []byte(""), nil },
	})
	if err != nil {
		return 
	}
	defer s.Shutdown()

	var mc []ModuleCase
	mc = append(mc, ModuleCase{
		Name: "Happy Path",
		Pass: true,
		ModuleConf: wasm.ModuleConfig{
			Name:     "A Module",
			PoolSize: 99,
			Filepath: os.Args[1],
		},
	})
	for _, m := range mc {
		err = s.LoadModule(m.ModuleConf)
		if err != nil {return}
	}
	return
}
