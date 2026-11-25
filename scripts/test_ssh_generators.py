#!/usr/bin/env python3

from __future__ import annotations

import json
import subprocess
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SCRIPTS_DIR = REPO_ROOT / "home/private_dot_config/chezmoi/scripts"
HOSTS_SCRIPT = SCRIPTS_DIR / "generate_ssh_hosts.py"
AGENT_SCRIPT = SCRIPTS_DIR / "generate_ssh_agent_config.py"

VALID_SHA256 = "SHA256:DU50O1aemDUDPjyVeF/YVWpRCjaKN6BPcaki+48r5E8"
VALID_MD5 = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"


def run_hosts(items: list[dict]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(HOSTS_SCRIPT)],
        input=json.dumps(items),
        text=True,
        capture_output=True,
        check=False,
    )


def run_agent(
    accounts: object, account: str, vault: str
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(AGENT_SCRIPT), "--account", account, "--vault", vault],
        input=json.dumps(accounts),
        text=True,
        capture_output=True,
        check=False,
    )


def make_item(
    title: str = "Server",
    url: str = "ssh://git@github.com",
    fingerprint: str = VALID_SHA256,
    hostname: str | None = None,
    user: str | None = None,
    port: str | None = None,
) -> dict:
    fields: list[dict[str, str]] = [
        {"type": "URL", "label": "url", "value": url},
        {"label": "fingerprint", "value": fingerprint},
    ]
    if hostname is not None:
        fields.append({"label": "hostname", "value": hostname})
    if user is not None:
        fields.append({"label": "user", "value": user})
    if port is not None:
        fields.append({"label": "port", "value": port})
    return {"title": title, "fields": fields}


class GenerateSshHostsTests(unittest.TestCase):
    def test_emits_valid_entries_sorted_by_title(self) -> None:
        items = [
            make_item(
                title="Zeta",
                url="ssh://deploy@app-prod:2222",
                hostname="10.0.0.5",
                fingerprint=VALID_MD5,
            ),
            make_item(
                title="Alpha",
                url="ssh://git@github.com",
                fingerprint=VALID_SHA256,
            ),
        ]
        result = run_hosts(items)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")

        expected = (
            "# 1Password Item: Alpha\n"
            "Host github.com\n"
            "    User git\n"
            "    IdentitiesOnly yes\n"
            "    IdentityFile ~/.ssh/1Password/SHA256_DU50O1aemDUDPjyVeF_YVWpRCjaKN6BPcaki+48r5E8.pub\n"
            "\n"
            "# 1Password Item: Zeta\n"
            "Host app-prod\n"
            "    HostName 10.0.0.5\n"
            "    User deploy\n"
            "    IdentitiesOnly yes\n"
            "    IdentityFile ~/.ssh/1Password/aa_bb_cc_dd_ee_ff_00_11_22_33_44_55_66_77_88_99.pub\n"
            "    Port 2222\n"
        )
        self.assertIn(expected, result.stdout)

    def test_sanitizes_control_characters_in_title(self) -> None:
        result = run_hosts([make_item(title="Prod\nProxyCommand sh -c evil\r\x00")])
        self.assertEqual(result.returncode, 0)
        self.assertIn("# 1Password Item: Prod ProxyCommand sh -c evil\n", result.stdout)
        self.assertNotIn("\nProxyCommand", result.stdout)

    def test_rejects_directive_injection_in_fields_and_urls(self) -> None:
        malicious_items = [
            make_item(title="host-wildcard", url="ssh://git@*"),
            make_item(title="host-leading-dash", url="ssh://git@-oProxyCommand=evil"),
            make_item(title="host-newline", url="ssh://git@github.com\nProxyCommand evil"),
            make_item(title="url-path", url="ssh://git@github.com/owner/repo"),
            make_item(title="url-password", url="ssh://git:secret@github.com"),
            make_item(title="url-query", url="ssh://git@github.com?foo=bar"),
            make_item(title="hostname-newline", hostname="example.com\nProxyCommand evil"),
            make_item(title="hostname-space", hostname="example.com ProxyCommand evil"),
            make_item(title="user-newline", user="git\nProxyCommand evil"),
            make_item(title="user-space", user="git evil"),
            make_item(title="fp-newline", fingerprint=f"{VALID_SHA256}\nProxyCommand evil"),
            make_item(title="fp-traversal", fingerprint="../../etc/passwd"),
            make_item(title="port-newline", port="22\nProxyCommand evil"),
            make_item(title="port-zero", port="0"),
            make_item(title="port-high", port="65536"),
            make_item(title="port-unicode-digit", port="²"),
        ]
        result = run_hosts(malicious_items)
        self.assertEqual(result.returncode, 0)
        self.assertNotIn("Host ", result.stdout)
        self.assertNotIn("ProxyCommand", result.stdout)
        self.assertNotIn("IdentityFile", result.stdout)
        self.assertIn("Warning: Skipping", result.stderr)

    def test_skips_duplicate_hosts_deterministically(self) -> None:
        items = [
            make_item(title="B-duplicate", url="ssh://git@github.com", fingerprint=VALID_MD5),
            make_item(title="A-winner", url="ssh://git@github.com", fingerprint=VALID_SHA256),
        ]
        result = run_hosts(items)
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.count("Host github.com\n"), 1)
        self.assertIn("1Password Item: A-winner", result.stdout)
        self.assertNotIn("1Password Item: B-duplicate", result.stdout)
        self.assertIn("Skipping duplicate SSH Host 'github.com'", result.stderr)


class GenerateSshAgentConfigTests(unittest.TestCase):
    ACCOUNTS = [
        {
            "account_uuid": "AAAAAAAAAAAAAAAAAAAAAAAAAA",
            "user_uuid": "UUUUUUUUUUUUUUUUUUUUUUUUUU",
            "url": "personal.1password.com",
            "email": "me@example.com",
        },
        {
            "account_uuid": "BBBBBBBBBBBBBBBBBBBBBBBBBB",
            "user_uuid": "VVVVVVVVVVVVVVVVVVVVVVVVVV",
            "url": "https://work.1password.com",
            "email": "me@work.example",
        },
    ]

    def test_resolves_by_subdomain_url_and_uuid(self) -> None:
        for selector, vault, expected_uuid in [
            ("personal", "Private", "AAAAAAAAAAAAAAAAAAAAAAAAAA"),
            ("personal.1password.com", "Private", "AAAAAAAAAAAAAAAAAAAAAAAAAA"),
            ("https://personal.1password.com/", "Private", "AAAAAAAAAAAAAAAAAAAAAAAAAA"),
            ("AAAAAAAAAAAAAAAAAAAAAAAAAA", "Private", "AAAAAAAAAAAAAAAAAAAAAAAAAA"),
            ("work", "Employee", "BBBBBBBBBBBBBBBBBBBBBBBBBB"),
            ("work.1password.com", "Employee", "BBBBBBBBBBBBBBBBBBBBBBBBBB"),
        ]:
            with self.subTest(selector=selector):
                result = run_agent(self.ACCOUNTS, selector, vault)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    result.stdout,
                    "# Generated by chezmoi. Do not edit manually.\n"
                    "[[ssh-keys]]\n"
                    f'account = "{expected_uuid}"\n'
                    f'vault = "{vault}"\n',
                )

    def test_rejects_unknown_or_ambiguous_account(self) -> None:
        missing = run_agent(self.ACCOUNTS, "other", "Private")
        self.assertNotEqual(missing.returncode, 0)
        self.assertIn("No signed-in 1Password account matched", missing.stderr)

        ambiguous_accounts = [
            {"account_uuid": "AAAAAAAAAAAAAAAAAAAAAAAAAA", "url": "acme.1password.com"},
            {"account_uuid": "BBBBBBBBBBBBBBBBBBBBBBBBBB", "url": "acme.1password.eu"},
        ]
        ambiguous = run_agent(ambiguous_accounts, "acme", "Employee")
        self.assertNotEqual(ambiguous.returncode, 0)
        self.assertIn("Multiple 1Password accounts matched", ambiguous.stderr)

    def test_rejects_malformed_uuid_or_vault(self) -> None:
        bad_accounts = [
            {"account_uuid": 'BAD"\n[evil]', "url": "personal.1password.com"},
        ]
        bad_uuid = run_agent(bad_accounts, "personal", "Private")
        self.assertNotEqual(bad_uuid.returncode, 0)

        bad_vault = run_agent(self.ACCOUNTS, "personal", "Private\n[[ssh-keys]]")
        self.assertNotEqual(bad_vault.returncode, 0)


if __name__ == "__main__":
    unittest.main()
