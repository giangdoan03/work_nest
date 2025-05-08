<?php
$passwordHash = '$2y$10$gEp69tYzzTae4H8gooFONuT2zXs7oCSLqf.VG7ivISXbrdUKhouZe';
$inputPassword = '123456';

var_dump(password_verify($inputPassword, $passwordHash));
