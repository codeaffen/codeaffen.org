---
layout: post
title: How to issue an asset on Stellar
subtitle: AFFEN goes live
tags: [poc, blockchain, stellar, token, asset, github]
author: gmzabos
---

## Intro - what is Stellar?

[Stellar](http://stellar.org/){:target="_blank"} is an open-source network for currencies and payments. It is public, there is no "real" owner as it is a decentralized network. See the [intro section](https://stellar.org/learn/intro-to-stellar){:target="_blank"} on their website, as it speaks for itself better than i could do.

## Intro - why do we issue our own asset?

We came up with the idea while experimenting with Stellar (and other blockchains) and decided to create an asset (or "token") to hook it up to [codeaffen on github](https://github.com/codeaffen){:target="_blank"}. The token would function within that ecosystem as a reward for the sake of gamification while submitting code & contributing in other ways to the project. Every good role-playing game has its own XP, you get the idea...
The token was named [AFFEN](https://stellar.expert/explorer/public/asset/AFFEN-GDIZF5MAUDQ6TLIK3PNZ2ESOJAZDNZWIB675S4SQ5RWUTZP3B3ONUPMX){:target="_blank"} (german: "monkey") and is represented by that neat and busy code monkey on our [logo](https://codeaffen.org/assets/img/Codeaffen_only_C_wo_bg.png){:target="_blank"}. There is a supply of 1,000,000 code monkeys to give away for contributing. AFFEN, anyone?

## Intro - where to start?

Best starting point is the [official Stellar documentation](https://developers.stellar.org/docs/issuing-assets/){:target="_blank"}, but there is also great public articles & videos regarding this topic. I recommend reading at least into the documentation before you start, just to get a feeling *what* to do and *why* to do it.

## Howto - let's go

- You will need an active wallet, which you use to fund *two* new accounts with. Make sure you have 5 XLM in that wallet which you can be transfered out into the *two* new accounts. I used my [Lobstr wallet](https://lobstr.co/){:target="_blank"} with an afor this.
- Access [Stellar Laboratory](https://laboratory.stellar.org/){:target="_blank"}. Select "public" on the top right corner.
- Create an ISSUER account: Click `Create Account`, then click `Generate keypair`. Note down the values for `Public Key` & `Secret Key`
- Create an DISTRIBUTOR account: Click again on `Generate keypair`, also note down the second set of values for `Public Key` & `Secret Key`
- Make sure you have noted both values for *each* account. Rule of thumb: do not *ever* hand out the `Secret Key` to anyone else, but you can share the `Public Key` *anytime*.

## Howto - fund ISSUER and DISTRIBUTOR accounts

- Activate the ISSUER account by sending 2 XLM to it through your Stellar wallet. Use the `Public Key` (ISSUER) as recipient.
- Activate the DISTRIBUTOR account by sending 3 XLM to it through your Stellar wallet. Use the `Public Key` (DISTRIBUTOR) as recipient.
- Give it a few seconds, then check both accounts on [stellar.expert](https://stellar.expert/explorer/public){:target="_blank"}. Both accounts should be active and present the amount of XLM, which you just transfered. Go on with...

## Howto - establish trustline from DISTRIBUTOR to ISSUER

- Access [Stellar Laboratory](https://laboratory.stellar.org/){:target="_blank"}. Select "public" on the top right corner.
- Select `Build Transaction`, paste the `Public Key` (DISTRIBUTOR) into the `Source Account` field
- Click `Fetch next sequence number for account starting with...`.
- Scroll down to `Operation Type` and select `Change Trust`.
- In the Asset field choose between `Alphanumeric 4` or `Alphanumeric 12`. This defines the possible length of your Asset Code.
- Enter your Asset Code in the corresponding field (e.g. `ABCDEF`). This will be your token's name. Note down your Asset Code.
- Enter the amount of tokens you want to generate into the `Trust Limit` field (e.g. 1,000,000)
- Scroll down to `Sign in Transaction Signer` and click it.
- Paste your `Private Key` (DISTRIBUTOR) into the `Add Signer` field.
- Scroll down to `Sign in Transaction Submitter` and click it.
- Scroll down to `Submit Transaction` and click it.

## Howto - send the new token from ISSUER to DISTRIBUTOR

- Access [Stellar Laboratory](https://laboratory.stellar.org/){:target="_blank"}. Select "public" on the top right corner.
- Select `Build Transaction`, paste the `Public Key` (ISSUER) into the `Source Account` field.
- Click `Fetch next sequence number for account starting with...`.
- Scroll down to `Operation Type` and select `Payment`
- Paste your `Public Key` (DISTRIBUTOR) in the `Destination` field.
- In the Asset field choose between `Alphanumeric 4` or `Alphanumeric 12` as the length for your Asset Code which you picked earlier.
- Below that enter your Asset Code (e.g. `ABCDEF`).
- Below that enter your `Public Key` (ISSUER).
- Choose the amount of your token you want to send to the DISTRIBUTOR (e.g. 1,000,000 for all token which you created earlier) in the `Amount` field.
- Scroll down to `Sign in Transaction Submitter` and click it.
- Scroll down to `Submit Transaction` and click it.
- Give it a minute, then check both accounts on [stellar.expert](https://stellar.expert/explorer/public){:target="_blank"}. Both accounts should present the amount of XLM, plus the amount of your new token (e.g. `ABCDEF`) on the DISTRIBUTOR account.

## Howto - publish information about your new token

Okay, that is your new token. In the process you have created *two* accounts by paying little XLM into both, established a trustline from DISTRIBUTOR account to ISSUER account, then you paid from the ISSUER to the DISTRIBUTOR account a specific amount of your new token. The DISTRIBUTOR account is going to handle outgoing transactions for your new token from now on.

Next: let's advertise your new token. The process is well defined in the [official Stellar documentation](https://developers.stellar.org/docs/issuing-assets/publishing-asset-info/){:target="_blank"}. All you need is to create a file called `stellar.toml` and host it on your domain/webservice. Follow the documentation and fill the required fields, decide for yourself what on optional information you want to provide. Also, this is the right place to add a link to a shiny logo for your new token.

{: .box-note}
**Important note:** As an example, we placed the `stellar.toml` file for our `AFFEN` token in `https://codeaffen.org/.well-known/stellar.toml`, because `codeaffen.org` is our home domain. This can be quite tricky, if you don't host your own domain, but maybe decided to use [Github Pages](https://pages.github.com/){:target="_blank"} with [jekyll](https://jekyllrb.com/){:target="_blank"} like we did. If you run into trouble just [contact](https://codeaffen.org/contact/){:target="_blank"} us.

As a last step, let's connect the home domain with the ISSUER account, so everybody knows where that new token comes from.

- Access [Stellar Laboratory](https://laboratory.stellar.org/){:target="_blank"}. Select "public" on the top right corner.
- Select `Build Transaction`, paste the `Public Key` (ISSUER) into the `Source Account` field.
- Click `Fetch next sequence number for account starting with...`.
- Scroll down to `Operation Type` and select `Set Options`.
- Scroll down to `Home Domain` and enter your home domain. You can skip the other fields.
- Scroll down to `Sign in Transaction Signer` and click it.
- Scroll down to `Add Signer` and paste the `Secret Key` (ISSUER).
- Scroll down to `Submit in Transaction Submitter` and click it.
- Scroll down to `Submit Transaction` and click it.
- Give it a minute, then check both accounts on [stellar.expert](https://stellar.expert/explorer/public){:target="_blank"}. Both accounts should present the amount of XLM, plus the amount of your new token (e.g. `ABCDEF`) on the DISTRIBUTOR account. On the ISSUER account you will see a new entry for `Home domain`, `Organization metadata` and `Principals`. Search for your token in `Assets` and you will find additional information in `Currency`

## Check your new token in your Stellar wallet

You can now add the new token / asset in your wallet, an active trustline from your Stellar wallet to the DISTRIBUTOR account is still necessary. On my Lobstr wallet, this is handled by the app itself while adding a new `Asset`. All this information should be reflected in your Stellar wallet, along with that nice logo, about a few hours later.

## What's next?

As i mentioned in the intro *why* we issue our own asset, the next steps will be to *automate* the whole process by writing some code and hook it up to Github. Stay tuned for our next episode!
