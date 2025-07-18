#-*-makefile-*-   ; force emacs to enter makefile-mode

# %CopyrightBegin%
#
# SPDX-License-Identifier: Apache-2.0
#
# Copyright Ericsson AB 2004-2025. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# %CopyrightEnd%

# The module 'snmp_pdus_basic' is generated from a hand crafted ASN.1 spec
MODULES = \
	snmp_pdus_basic \
	snmp_conf       \
	snmp_config     \
	snmp_log        \
	snmp_mini_mib   \
	snmp_misc       \
	snmp_note_store \
	snmp_pdus       \
	snmp_usm        \
        snmp_verbosity

HRLS = \
	snmp_verbosity \
	snmp_debug \
	snmp_usm

ASN1_SPECS = snmp_pdus_basic
