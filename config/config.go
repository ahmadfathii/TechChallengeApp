// Copyright © 2022 Servian
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

package config

import (
	"strings"

	"github.com/spf13/viper"
)

// internalConfig wraps the config values as the toml library was
// having issue with getters and setters on the struct
type Config struct {
	DbUser     string
	DbPassword string
	DbName     string
	DbHost     string
	DbPort     string
	DbType     string
	ListenHost string
	ListenPort string
}

func LoadConfig() (*Config, error) {
	var conf = &Config{}

	v := viper.New()

	v.SetConfigName("conf")
	v.SetConfigType("toml")
	v.AddConfigPath(".")

	v.SetEnvPrefix("VTT")
	v.AutomaticEnv()

	v.SetDefault("DBUSER", "postgres")
	v.SetDefault("DBPASSWORD", "postgres")
	v.SetDefault("DBNAME", "postgres")
	v.SetDefault("DBPORT", "postgres")
	v.SetDefault("DBHOST", "0.0.0.0")
	v.SetDefault("DBTYPE", "postgres")

	v.SetDefault("LISTENHOST", "0.0.0.0")
	v.SetDefault("LISTENPORT", "3000")

	err := v.ReadInConfig() // Find and read the config file

	if err != nil {
		return nil, err
	}

	conf.DbUser = strings.TrimSpace(v.GetString("DBUSER"))
	conf.DbPassword = strings.TrimSpace(v.GetString("DBPASSWORD"))
	conf.DbName = strings.TrimSpace(v.GetString("DBNAME"))
	conf.DbHost = strings.TrimSpace(v.GetString("DBHOST"))
	conf.DbPort = strings.TrimSpace(v.GetString("DBPORT"))
	conf.DbType = strings.TrimSpace(v.GetString("DBTYPE"))
	conf.ListenHost = strings.TrimSpace(v.GetString("LISTENHOST"))
	conf.ListenPort = strings.TrimSpace(v.GetString("LISTENPORT"))

	return conf, nil
}
