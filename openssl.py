from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import serialization
import binascii
#https://cryptography.io/en/latest/hazmat/primitives/asymmetric/ec/#cryptography.hazmat.primitives.asymmetric.ec.EllipticCurvePrivateKey

#def point_addition(Px, Py, Qx, Qy, message):


bob_key = raw_input("Enter Bob's private key: ")
bob_private_key = ec.derive_private_key(int(bob_key), ec.SECP256K1(), default_backend())
bob_priv_val = bob_private_key.private_numbers().private_value
bob_public_key = bob_private_key.public_key()
print "Bob's private key is: " + hex(bob_priv_val)
print "Bob's public x coord is: " + hex(bob_public_key.public_numbers().x)
print "Bob's public y coord is: " + hex(bob_public_key.public_numbers().y)

alice_priv = raw_input("Enter Alice's private key: ")
alice_private_key = ec.derive_private_key(int(alice_priv), ec.SECP256K1(), default_backend())
alice_priv_val = alice_private_key.private_numbers().private_value
alice_public_key = alice_private_key.public_key()
print "Alice's private key is: " + hex(alice_priv_val)
print "Alice's public x coord is: " + hex(alice_public_key.public_numbers().x)
print "Alice's public y coord is: " + hex(alice_public_key.public_numbers().y)

shared_key = bob_private_key.exchange(ec.ECDH(), alice_public_key)
test = hex(int(bin(int(binascii.hexlify(shared_key),16)),2))
print "Shared secret is: " + test
