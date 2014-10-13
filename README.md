# BlackVoid Vote

This is a simple voting system for Garrysmod, which provides an API for other addons/gamemodes to start votes.

Feel free to modify and send pull requests.

## 1. Functions:

**Serverside:**
    
    -- Start vote
    -- Players (table) - Table containing players ex. {Player(1), Player(2)} or player.GetAll()
    -- Title (string) - Name of vote
    -- Options (table) - Table containing all options ex.
    --                   {{["id"] = "internal_id_1", ["value"] = "Value shown"}, {["id"] = "internal_id_2", ["value"] = "Value shown 2"}}
    -- VoteDuration (integer) - How long the vote lasts in seconds.
    -- Callback (function) - function called when vote is over.
    --     plTbl (table) - Participants
    --     option (table) - Winning option ex.
    --         {
    --             ["id"] = "internal_id_1",
    --             ["value"] = "Value shown",
    --             ["votes"] = 10
    --         }
    function BVVote.StartVote(Players, Title, Options, VoteDuration, Callback(plTbl, option))

## 3. License
BlackVoid Vote has been released under the MIT Open Source license, unless otherwise mentioned.  All contributors agree to transfer ownership of their code to Felix Gustavsson for release under this license.

### 3.1 The MIT License

Copyright (C) 2014 Felix Gustavsson and contributors.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
