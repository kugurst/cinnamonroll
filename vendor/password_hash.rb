# Password Hashing With PBKDF2 (http://crackstation.net/hashing-security.htm).
# Copyright (c) 2013, Taylor Hornby
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'securerandom'
require 'openssl'
require 'base64'

# Salted password hashing with PBKDF2-SHA1.
# Authors: @RedragonX (dicesoft.net), havoc AT defuse.ca
# www: http://crackstation.net/hashing-security.htm
# modified by Mark Aligbe
module PasswordHash

  # The following constants can be changed without breaking existing hashes.
  PBKDF2_ITERATIONS = 5000
  SALT_BYTE_SIZE = 128
  HASH_BYTE_SIZE = 128

  HASH_SECTIONS = 2
  SECTION_DELIMITER = ':'
  SALT_INDEX = 0
  HASH_INDEX = 1

  # Returns a salted PBKDF2 hash of the password.
  def self.createHash( password )
    dig = OpenSSL::Digest::SHA256.new
    salt = SecureRandom.base64( SALT_BYTE_SIZE )
    pbkdf2 = OpenSSL::PKCS5::pbkdf2_hmac(
      password,
      salt,
      PBKDF2_ITERATIONS,
      HASH_BYTE_SIZE,
      dig
    )
    return [salt, Base64.strict_encode64( pbkdf2 )].join( SECTION_DELIMITER )
  end

  def self.eql_time_cmp(a, b)
    unless a.length == b.length
      return false
    end
    cmp = b.bytes.to_a
    result = 0
    a.bytes.each_with_index {|c,i|
      result |= c ^ cmp[i]
    }
    result == 0
  end

  # Checks if a password is correct given a hash of the correct one.
  # correctHash must be a hash string generated with createHash.
  def self.validatePassword( password, correctHash )
    params = correctHash.split( SECTION_DELIMITER )
    return false if params.length != HASH_SECTIONS

    dig = OpenSSL::Digest::SHA256.new
    pbkdf2 = Base64.decode64( params[HASH_INDEX] )
    testHash = OpenSSL::PKCS5::pbkdf2_hmac(
      password,
      params[SALT_INDEX],
      PBKDF2_ITERATIONS,
      pbkdf2.length,
      dig
    )

    return eql_time_cmp(testHash, pbkdf2)
    # return testHash == pbkdf2
  end

  # Run tests to ensure the module is functioning properly.
  # Returns true if all tests succeed, false if not.
  def self.runSelfTests
    puts "Sample hashes:"
    3.times { puts createHash("password") }

    puts "\nRunning self tests..."
    @@allPass = true

    correctPassword = 'aaaaaaaaaa'
    wrongPassword = 'aaaaaaaaab'
    hash = createHash(correctPassword)

    assert( validatePassword( correctPassword, hash ) == true, "correct password" )
    assert( validatePassword( wrongPassword, hash ) == false, "wrong password" )

    h1 = hash.split( SECTION_DELIMITER )
    h2 = createHash( correctPassword ).split( SECTION_DELIMITER )
    assert( h1[HASH_INDEX] != h2[HASH_INDEX], "different hashes" )
    assert( h1[SALT_INDEX] != h2[SALT_INDEX], "different salt" )

    if @@allPass
      puts "*** ALL TESTS PASS ***"
    else
      puts "*** FAILURES ***"
    end

    return @@allPass
  end

  def self.assert( truth, msg )
    if truth
      puts "PASS [#{msg}]"
    else
      puts "FAIL [#{msg}]"
      @@allPass = false
    end
  end

end

# PasswordHash.runSelfTests
