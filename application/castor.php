<?php

use Castor\Attribute\AsTask;

use function Castor\io;
use function Castor\capture;

#[AsTask(description: 'Run the CI')]
function ci(): void
{
    $currentUser = capture('whoami');

    io()->title(sprintf('Hello %s!', $currentUser));
}